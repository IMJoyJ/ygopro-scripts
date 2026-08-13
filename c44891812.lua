--超重武者オタス－K
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，自己的守备表示怪兽和对方怪兽进行战斗的伤害计算时把这张卡从手卡丢弃，以进行战斗的怪兽以外的自己场上1只「超重武者」怪兽为对象才能发动。那只进行战斗的自己怪兽的守备力只在那次伤害计算时上升作为对象的怪兽的守备力数值。
-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽特殊召唤。
function c44891812.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，自己的守备表示怪兽和对方怪兽进行战斗的伤害计算时把这张卡从手卡丢弃，以进行战斗的怪兽以外的自己场上1只「超重武者」怪兽为对象才能发动。那只进行战斗的自己怪兽的守备力只在那次伤害计算时上升作为对象的怪兽的守备力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44891812,0))
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c44891812.defcon)
	e1:SetCost(c44891812.defcost)
	e1:SetTarget(c44891812.deftg)
	e1:SetOperation(c44891812.defop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44891812,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c44891812.spcon)
	-- 设置效果②的发动代价为把墓地中的这张卡除外（使用aux.bfgcost简化实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44891812.sptg)
	e2:SetOperation(c44891812.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数：确认自己墓地中没有魔法·陷阱卡存在。
function c44891812.defcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地中魔法·陷阱卡的数量是否为0。
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)==0
end
-- 效果①的发动代价函数：将手卡的这张卡丢弃作为发动代价。
function c44891812.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡丢弃送入墓地，原因标记为COST（代价）和DISCARD（丢弃）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的对象过滤器：用于选择自己场上的表侧表示、卡名含有「超重武者」字段、且守备力不为0的怪兽。
function c44891812.deffilter(c)
	-- 对象必须满足：表侧表示、属于0x9a（超重武者）字段、且守备力不为0。
	return c:IsFaceup() and c:IsSetCard(0x9a) and aux.nzdef(c)
end
-- 效果①的发动目标处理：获取攻击怪兽和战斗对象，并处理取对象效果的合法性检测。
function c44891812.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行战斗的攻击方怪兽。
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and c44891812.deffilter(chkc) and chkc~=e:GetLabelObject() end
	if chk==0 then return a and a:IsDefensePos() and d and d:IsControler(1-tp)
		-- 检查除攻击怪兽外，自己场上是否存在1只满足条件的「超重武者」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c44891812.deffilter,tp,LOCATION_MZONE,0,1,a) end
	-- 向玩家发出“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的「超重武者」怪兽作为效果对象。
	Duel.SelectTarget(tp,c44891812.deffilter,tp,LOCATION_MZONE,0,1,1,a)
	e:SetLabelObject(a)
end
-- 效果①处理：使进行战斗的自己怪兽的守备力仅在那次伤害计算时上升作为对象的怪兽的守备力数值。
function c44891812.defop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（被取为对象的「超重武者」怪兽，其守备力数值将被用于提升）。
	local tc=Duel.GetFirstTarget()
	local ac=e:GetLabelObject()
	if ac:IsRelateToBattle() and ac:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只进行战斗的自己怪兽的守备力只在那次伤害计算时上升作为对象的怪兽的守备力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(tc:GetDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		ac:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判定函数：对方怪兽进行直接攻击宣言。
function c44891812.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	-- 攻击怪兽是对方怪兽且攻击对象为空，即直接攻击。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果②的对象过滤器：墓地中属于「超重武者」字段且可以被特殊召唤的怪兽。
function c44891812.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象合法性检查：只能选择自己墓地中满足特殊召唤条件的「超重武者」怪兽，且不能选择效果②自身这张卡。
function c44891812.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and c44891812.spfilter(chkc,e,tp) and chkc~=c end
	-- 发动条件检查：自己主要怪兽区存在可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在满足特殊召唤条件的「超重武者」怪兽。
		and Duel.IsExistingTarget(c44891812.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 向玩家发出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只「超重武者」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c44891812.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 设置连锁处理信息，标明该效果处理时将进行特殊召唤，对象为选择的那1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②处理：将选择的怪兽特殊召唤。
function c44891812.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（墓地中选出的「超重武者」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示形式特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
