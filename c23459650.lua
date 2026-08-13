--ネフティスの輪廻
-- 效果：
-- 「奈芙提斯」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「奈芙提斯」仪式怪兽仪式召唤。把「奈芙提斯之祭祀者」或者「奈芙提斯之苍凰神」解放作仪式召唤的场合，可以再选场上1张卡破坏。
function c23459650.initial_effect(c)
	-- 在该卡上登记“奈芙提斯之祭祀者”和“奈芙提斯之苍凰神”的卡号，以标记该卡效果文字中记载了这些卡名，供其他卡识别或检索。
	aux.AddCodeList(c,88176533,24175232)
	-- 为这张仪式魔法卡注册仪式召唤效果：可解放自己手牌·场上的怪兽，从手牌仪式召唤1只「奈芙提斯」仪式怪兽，等级合计可大于等于所需等级；并挂接额外的追加破坏操作函数extraop。
	aux.AddRitualProcGreater2(c,c23459650.filter,LOCATION_HAND,nil,nil,false,c23459650.extraop)
end
-- 仪式召唤对象的过滤函数：判定候选卡是否为「奈芙提斯」系列的仪式怪兽（用于选择手牌中可仪式召唤的怪兽）。
function c23459650.filter(c,e,tp)
	return c:IsSetCard(0x11f)
end
-- 追加破坏效果的素材过滤函数：用于判断作为仪式召唤解放的素材中是否包含「奈芙提斯之祭祀者」或「奈芙提斯之苍凰神」；若素材来自场上，则通过其在场上时的原卡号判定，若来自手牌则直接判定卡号。
function c23459650.mfilter(c)
	if c:IsPreviousLocation(LOCATION_MZONE) then
		local code,code2=c:GetPreviousCodeOnField()
		return code==88176533 or code==24175232 or code2==88176533 or code2==24175232
	end
	return c:IsCode(88176533,24175232)
end
-- 仪式召唤成功后的追加效果处理函数：当祭品中存在「奈芙提斯之祭祀者」或「奈芙提斯之苍凰神」时，询问玩家是否再选场上1张卡破坏；若同意，则中断当前处理并让玩家选择场上1张卡进行破坏。
function c23459650.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	-- 获取场上前后场所有卡（除这张仪式魔法卡自身外），作为可选破坏对象的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 确认祭品集合中存在「奈芙提斯之祭祀者」或「奈芙提斯之苍凰神」，且场上有可选卡片时，向玩家询问是否发动追加的破坏效果。
	if mat:IsExists(c23459650.mfilter,1,nil) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(23459650,0)) then  --"是否把卡破坏？"
		-- 中断当前效果处理，使追加的破坏效果成为独立的一段处理，避免与仪式召唤处理同时进行而影响时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要破坏的卡”的选择提示，为接下来的选卡操作设置提示文字。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,e:GetHandler())
		-- 将玩家选择的那张卡以效果原因破坏送入墓地。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
