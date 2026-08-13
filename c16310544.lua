--御巫神楽
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「御巫」仪式怪兽仪式召唤。那之后，以下效果可以适用。
-- ●把最多有自己墓地的装备魔法卡种类数量的对方场上的卡破坏，给与对方破坏数量×1000伤害。
function c16310544.initial_effect(c)
	-- 为御巫神乐注册仪式召唤效果：以等级合计可大于等于仪式怪兽等级的仪式召唤方式，从手卡将「御巫」仪式怪兽仪式召唤，并在召唤成功后执行extraop追加效果（pause=true表示暂不直接注册，由额外参数控制后续操作）。
	local e1=aux.AddRitualProcGreater2(c,c16310544.filter,LOCATION_HAND,nil,nil,true,c16310544.extraop)
	e1:SetCountLimit(1,16310544+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
-- 定义仪式召唤可用怪兽的过滤函数：判断仪式怪兽是否为卡名含有「御巫」（0x18d）字段的怪兽。
function c16310544.filter(c,e,tp)
	return c:IsSetCard(0x18d)
end
-- 仪式召唤成功后的追加效果处理函数：若仪式召唤成功，则计算自己墓地装备魔法卡的种类数，获取对方场上的全部卡，在玩家选择适用后，从对方场上选择至多该种类数量的卡破坏，并给对方造成破坏数量×1000的伤害。
function c16310544.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	-- 获取自己墓地的装备魔法卡（TYPE_EQUIP），并按卡名（Card.GetCode）统计种类数量，用于决定可破坏的卡数量上限。
	local ct=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_EQUIP):GetClassCount(Card.GetCode)
	-- 获取对方场上所有表侧或里侧表示的卡（LOCATION_ONFIELD），作为可被追加效果破坏的候选对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 判断是否满足追加效果的发动条件：墓地有装备魔法卡种类（ct>0）、对方场上有卡（#g>0），并询问玩家是否选择破坏对方场上的卡。
	if ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(16310544,0)) then  --"是否选对方场上的卡破坏？"
		-- 中断当前效果处理，使之后的破坏和伤害处理与之前的仪式召唤效果视为不同时处理，避免错误的时点判定。
		Duel.BreakEffect()
		-- 向玩家发送选择提示消息，要求从候选的对方场上卡片中选择要破坏的卡（HINTMSG_DESTROY）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,ct,nil)
		-- 手动展示玩家所选卡片被选中为对象的动画，并记录这些卡被选为对象。
		Duel.HintSelection(sg)
		-- 以效果原因破坏玩家选择的对方场上卡片（sg），并返回实际被破坏的卡数量，用于后续伤害计算。
		local res=Duel.Destroy(sg,REASON_EFFECT)
		-- 根据实际破坏数量res，给对方玩家（1-tp）造成res×1000点效果伤害。
		Duel.Damage(1-tp,res*1000,REASON_EFFECT)
	end
end
