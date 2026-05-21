--ダイスロール・バトル
-- 效果：
-- ①：对方怪兽的攻击宣言时以自己墓地1只「疾行机人」怪兽为对象才能发动。那只怪兽和手卡1只「疾行机人」调整除外，把持有和那2只的原本等级合计相同等级的1只同调怪兽从额外卡组特殊召唤。
-- ②：对方战斗步骤把墓地的这张卡除外，以自己以及对方场上的表侧攻击表示的同调怪兽各1只为对象才能发动。那只对方的表侧攻击表示怪兽向那只自己怪兽作出攻击，进行伤害计算。
function c88482761.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时以自己墓地1只「疾行机人」怪兽为对象才能发动。那只怪兽和手卡1只「疾行机人」调整除外，把持有和那2只的原本等级合计相同等级的1只同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c88482761.condition)
	e1:SetTarget(c88482761.target)
	e1:SetOperation(c88482761.operation)
	c:RegisterEffect(e1)
	-- ②：对方战斗步骤把墓地的这张卡除外，以自己以及对方场上的表侧攻击表示的同调怪兽各1只为对象才能发动。那只对方的表侧攻击表示怪兽向那只自己怪兽作出攻击，进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88482761,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c88482761.atkcon)
	-- 将墓地的这张卡除外作为发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c88482761.atktg)
	e2:SetOperation(c88482761.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c88482761.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方（即在对方回合发动）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤自己墓地中可以除外的「疾行机人」怪兽，且手牌中存在可与其配合进行同调召唤的「疾行机人」调整
function c88482761.rmfilter1(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsAbleToRemove()
		-- 检查手牌中是否存在满足条件的「疾行机人」调整怪兽
		and Duel.IsExistingMatchingCard(c88482761.rmfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalLevel())
end
-- 过滤手牌中可以除外的「疾行机人」调整怪兽，且额外卡组中存在等级等于两者原本等级合计的同调怪兽
function c88482761.rmfilter2(c,e,tp,lv)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		-- 检查额外卡组中是否存在等级等于两者原本等级合计的同调怪兽
		and Duel.IsExistingMatchingCard(c88482761.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetOriginalLevel()+lv)
end
-- 过滤额外卡组中可以特殊召唤的、等级等于指定数值的同调怪兽
function c88482761.spfilter(c,e,tp,lv)
	-- 过滤等级为lv的同调怪兽，且该怪兽可以特殊召唤，并且额外怪兽区域有可用空位
	return c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动准备与目标选择函数
function c88482761.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88482761.rmfilter1(chkc,e,tp) end
	-- 检查自己墓地是否存在满足条件的「疾行机人」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c88482761.rmfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只「疾行机人」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88482761.rmfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：从墓地除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理（除外并特殊召唤）函数
function c88482761.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地中的「疾行机人」怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetOriginalLevel()
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1只满足等级合计条件的「疾行机人」调整怪兽
	local g=Duel.SelectMatchingCard(tp,c88482761.rmfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		lv=lv+g:GetFirst():GetOriginalLevel()
		g:AddCard(tc)
		-- 将选中的墓地怪兽和手牌怪兽除外，并判断是否成功除外了2张卡
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
			-- 提示玩家选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只等级等于除外怪兽原本等级合计的同调怪兽
			local sg=Duel.SelectMatchingCard(tp,c88482761.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
			-- 将选中的同调怪兽在自己场上表侧攻击表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的发动条件判定函数
function c88482761.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的战斗步骤
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_BATTLE_STEP
end
-- 过滤场上表侧攻击表示的同调怪兽
function c88482761.atkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果②的发动准备与目标选择函数
function c88482761.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在表侧攻击表示的同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c88482761.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在表侧攻击表示的同调怪兽
		and Duel.IsExistingTarget(c88482761.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧攻击表示的同调怪兽作为对象
	Duel.SelectTarget(tp,c88482761.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧攻击表示的同调怪兽作为对象，并将其保存为标签对象以便后续识别
	local g2=Duel.SelectTarget(tp,c88482761.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
end
-- 效果②的效果处理（强制攻击并伤害计算）函数
function c88482761.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		local c1=g:GetFirst()
		local c2=g:GetNext()
		if c1~=e:GetLabelObject() then c1,c2=c2,c1 end
		if c1:IsControler(1-tp) and c1:IsPosition(POS_FACEUP_ATTACK) and not c1:IsImmuneToEffect(e)
			and c2:IsControler(tp) then
			-- 令对方的同调怪兽向自己的同调怪兽发起攻击并进行伤害计算
			Duel.CalculateDamage(c1,c2,true)
		end
	end
end
