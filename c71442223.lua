--方界輪廻
-- 效果：
-- ①：对方怪兽的直接攻击宣言时，以那1只攻击怪兽为对象才能发动。对方把那些同名怪兽尽可能从自身的手卡·卡组·墓地攻击表示特殊召唤。作为对象的怪兽以及这个效果特殊召唤的怪兽的攻击力变成0，给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。并且，再从自己手卡把1只4星以下的「方界」怪兽无视召唤条件特殊召唤。
function c71442223.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时，以那1只攻击怪兽为对象才能发动。对方把那些同名怪兽尽可能从自身的手卡·卡组·墓地攻击表示特殊召唤。作为对象的怪兽以及这个效果特殊召唤的怪兽的攻击力变成0，给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。并且，再从自己手卡把1只4星以下的「方界」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c71442223.condition)
	e1:SetTarget(c71442223.target)
	e1:SetOperation(c71442223.activate)
	c:RegisterEffect(e1)
end
c71442223.mentioned_counter={
	[0x1038]=true,
}
-- ①效果发动条件：对方怪兽进行直接攻击
function c71442223.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击者为对方且为直接攻击
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 手牌特召对象过滤：4星以下的「方界」怪兽
function c71442223.spfilter1(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果发动准备：选择攻击怪兽为对象并设置特召操作信息
function c71442223.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击宣言的怪兽
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	if chk==0 then return at:IsOnField() and at:IsCanBeEffectTarget(e)
		-- 发动条件检查：手牌是否存在可特召的4星以下「方界」怪兽
		and Duel.IsExistingMatchingCard(c71442223.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 发动条件检查：玩家是否可以放置指示物
		and Duel.IsCanAddCounter(tp) end
	-- 将攻击怪兽设为连锁对象
	Duel.SetTargetCard(at)
	-- 设置连锁操作信息：从手牌特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 同名怪兽特召过滤：与对象怪兽同名且能攻击表示特召
function c71442223.spfilter2(c,e,tp,tc)
	return c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果处理：对方尽可能特召同名怪兽，攻击力变0并放置方界指示物，随后从手牌特召「方界」怪兽
function c71442223.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local tg=Group.FromCards(tc)
		-- 获取对方场上空余的怪兽区域数量
		local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		-- 搜寻对方手卡·卡组·墓地中所有与对象怪兽同名的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c71442223.spfilter2),1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,1-tp,tc)
		if ft>0 and g:GetCount()>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft=1 end
			local sg=g:Clone()
			if g:GetCount()>ft then
				-- 提示对方玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sg=g:Select(1-tp,ft,ft,nil)
				g:Remove(Card.IsLocation,nil,LOCATION_MZONE+LOCATION_GRAVE)
				-- 将超出特召上限的剩余同名卡送去墓地
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
			local sc=sg:GetFirst()
			while sc do
				-- 分步攻击表示特殊召唤对方同名怪兽
				Duel.SpecialSummonStep(sc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
				sc=sg:GetNext()
			end
			-- 完成对方同名怪兽的特殊召唤
			Duel.SpecialSummonComplete()
			-- 获取成功特殊召唤的怪兽组
			local og=Duel.GetOperatedGroup()
			tg:Merge(og)
		end
		local tc=tg:GetFirst()
		while tc do
			c71442223.counter(tc,c)
			tc=tg:GetNext()
		end
		-- 分隔效果处理步骤
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的「方界」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只4星以下的「方界」怪兽
		local g2=Duel.SelectMatchingCard(tp,c71442223.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 无视召唤条件特殊召唤选中的「方界」怪兽
			Duel.SpecialSummon(g2,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 指示物效果生效条件：该怪兽放置有方界指示物
function c71442223.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 给目标怪兽攻击力变为0、放置方界指示物并施加不能攻击且效果无效的持续效果
function c71442223.counter(tc,ec)
	-- 攻击力变成0的效果
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	tc:AddCounter(0x1038,1)
	-- 有方界指示物放置的怪兽不能攻击，效果无效化的效果
	local e2=Effect.CreateEffect(ec)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c71442223.disable)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE)
	tc:RegisterEffect(e3)
end
