
          // Row(
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         Get.to(() => Displayfirendsprofile(
          //             FrienduId: widget.post['friendUid']));
          //       },
          //       child: CircleAvatar(
          //         backgroundImage:
          //             NetworkImage(widget.post['userProfileImage'] ?? ''),
          //         radius: 20,
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         GestureDetector(
          //           onTap: () {
          //             Get.to(() => Displayfirendsprofile(
          //                 FrienduId: widget.post['friendUid']));
          //           },
          //           child: Row(
          //             children: [
          //               Text(
          //                 widget.post['userName'] ?? '',
          //                 style: const TextStyle(
          //                     fontWeight: FontWeight.bold, fontSize: 16),
          //               ),
          //               const SizedBox(width: 4),
          //               if (widget.post['accountType'] == 'Celebrities / VIPs')
          //                 Image.asset('assets/images/verifiyed.png'),
          //             ],
          //           ),
          //         ),
          //         Text(
          //           '${widget.post['followersCount'] ?? 0} Followers',
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Colors.grey[600],
          //           ),
          //         ),
          //       ],
          //     ),
          //     const Spacer(),
          //     if (!isFriend)
          //       isRequested
          //           ? ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.grey,
          //                 padding: const EdgeInsets.symmetric(
          //                     horizontal: 16, vertical: 8),
          //                 shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(20)),
          //               ),
          //               onPressed: cancelFollowRequest,
          //               child: const Text("Requested",
          //                   style:
          //                       TextStyle(color: Colors.white, fontSize: 14)),
          //             )
          //           : ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: purpal,
          //                 padding: const EdgeInsets.symmetric(
          //                     horizontal: 16, vertical: 8),
          //                 shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(20)),
          //               ),
          //               onPressed: () async {
          //                 await sendFollowRequest();
          //                 await checkFriendStatus();
          //               },
          //               child: const Text("+Follow",
          //                   style:
          //                       TextStyle(color: Colors.white, fontSize: 14)),
          //             ),

          //             IconButton(onPressed: (){}, icon: Icon(Icons.more_vert,color: Colors.grey,)),
          //   ],
          // ),
