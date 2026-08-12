--ネフティスの輪廻
-- 效果：
-- 「奈芙提斯」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「奈芙提斯」仪式怪兽仪式召唤。把「奈芙提斯之祭祀者」或者「奈芙提斯之苍凰神」解放作仪式召唤的场合，可以再选场上1张卡破坏。
function c23459650.initial_effect(c)
	-- 记录该卡为「奈芙提斯」系列仪式怪兽的降临必需卡
	aux.AddCodeList(c,88176533,24175232)
	-- 注册仪式召唤程序，满足等级合计条件后从手卡仪式召唤「奈芙提斯」仪式怪兽
	aux.AddRitualProcGreater2(c,c23459650.filter,LOCATION_HAND,nil,nil,false,c23459650.extraop)
end
-- 筛选可以被仪式召唤的「奈芙提斯」系列怪兽
function c23459650.filter(c,e,tp)
	return c:IsSetCard(0x11f)
end
-- 判断解放的怪兽是否为「奈芙提斯之祭祀者」或「奈芙提斯之苍凰神」
function c23459650.mfilter(c)
	if c:IsPreviousLocation(LOCATION_MZONE) then
		local code,code2=c:GetPreviousCodeOnField()
		return code==88176533 or code==24175232 or code2==88176533 or code2==24175232
	end
	return c:IsCode(88176533,24175232)
end
-- 仪式召唤成功后，若满足条件则询问是否破坏场上一张卡
function c23459650.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	-- 获取场上所有满足条件的卡组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 判断是否有「奈芙提斯」系列怪兽被解放，并询问是否破坏卡
	if mat:IsExists(c23459650.mfilter,1,nil) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(23459650,0)) then  --"是否把卡破坏？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,e:GetHandler())
		-- 将选择的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
