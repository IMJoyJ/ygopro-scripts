--ファイヤー・エジェクション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只炎族怪兽送去墓地。这个效果把「火山」怪兽送去墓地的场合，可以再从以下效果选1个适用。
-- ●给与对方那个等级×100伤害。
-- ●在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
function c11654067.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只炎族怪兽送去墓地。这个效果把「火山」怪兽送去墓地的场合，可以再从以下效果选1个适用。●给与对方那个等级×100伤害。●在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11654067+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11654067.target)
	e1:SetOperation(c11654067.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：从卡组中选出满足“炎族”且可以被效果送去墓地的怪兽。
function c11654067.tgfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToGrave()
end
-- 效果发动时的目标判定与操作信息登记：检查卡组是否存在符合条件的炎族怪兽，并将“从卡组送去墓地”的操作信息写入当前连锁。
function c11654067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若卡组中不存在1只以上符合条件的炎族怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11654067.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁将执行的“从卡组把1张卡送去墓地”的操作信息（用于后续时点与相关效果判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并送去1只炎族怪兽；若送墓的是「火山」怪兽，则让玩家选择追加伤害或特招衍生物。
function c11654067.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选出1只符合条件的炎族怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c11654067.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认该怪兽成功被效果送去墓地，且该卡拥有「火山」字段时，进入追加效果分支。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsSetCard(0x32) then
		local b1=tc:GetLevel()>0
		-- 检查对方场上是否有可用的主要怪兽区域，以确定能否特殊召唤衍生物。
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			-- 确认可以在我方视角下将1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）以表侧表示特殊召唤到对方场上。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,11654068,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp)
		-- 弹出选项菜单，让当前玩家在“给与伤害”“特殊召唤衍生物”“什么都不做”中选择一项。
		local sel=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(11654067,0)},  --"给与对方伤害"
			{b2,aux.Stringid(11654067,1)},  --"特殊召唤衍生物"
			{true,aux.Stringid(11654067,2)})  --"什么都不做"
		if sel==1 then
			-- 中断当前效果链，使后续伤害处理作为独立事件，避免错失时点。
			Duel.BreakEffect()
			local val=tc:GetLevel()*100
			-- 给予对方玩家那只火山怪兽的等级×100数值的伤害。
			Duel.Damage(1-tp,val,REASON_EFFECT)
		elseif sel==2 then
			-- 中断当前效果链，使接下来的衍生物特殊召唤作为独立处理，避免时点被占用。
			Duel.BreakEffect()
			-- 生成1只「炸弹衍生物」的TOKEN（炎族·炎·1星·攻/守1000）。
			local token=Duel.CreateToken(tp,11654068)
			-- 将衍生物以表侧表示特殊召唤到对方场上；若成功，继续为其注册破坏时造成伤害的效果。
			if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
				-- 这衍生物被破坏时那个控制者受到500伤害。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_LEAVE_FIELD)
				e1:SetOperation(c11654067.damop)
				token:RegisterEffect(e1,true)
			end
			-- 结束多步特殊召唤流程，触发特殊召唤成功相关时点。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 衍生物离场（破坏）时的诱发效果：给其原来的控制者造成500伤害，并清除该效果。
function c11654067.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 对衍生物被破坏前的控制者给予500点效果伤害。
		Duel.Damage(c:GetPreviousControler(),500,REASON_EFFECT)
	end
	e:Reset()
end
