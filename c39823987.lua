--太陽龍インティ
-- 效果：
-- 「赤蚁」＋调整以外的怪兽1只以上
-- ①：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏，给与对方那个攻击力一半数值的伤害。
-- ②：场上的这张卡被破坏的下个回合的准备阶段，以自己墓地1只「月影龙 基利亚」为对象才能发动。那只怪兽特殊召唤。
function c39823987.initial_effect(c)
	-- 为该怪兽添加融合召唤所需的素材代码列表，允许使用卡号为78275321的「赤蚁」作为融合素材
	aux.AddMaterialCodeList(c,78275321)
	-- 设置该怪兽的同调召唤手续，要求1只「赤蚁」（卡号78275321）作为调整，以及1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,78275321),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏，给与对方那个攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39823987,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c39823987.descon)
	e1:SetTarget(c39823987.destg)
	e1:SetOperation(c39823987.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏的下个回合的准备阶段，以自己墓地1只「月影龙 基利亚」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c39823987.regcon)
	e2:SetOperation(c39823987.regop)
	c:RegisterEffect(e2)
end
-- 判断该怪兽是否在墓地且被战斗破坏
function c39823987.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置连锁处理时的破坏和伤害效果目标
function c39823987.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetReasonCard()
	if tc:IsRelateToBattle() then
		-- 设置将破坏目标怪兽的类别信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
		-- 设置将给对方造成伤害的类别信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(tc:GetAttack()/2))
	end
end
-- 执行破坏和伤害效果的操作
function c39823987.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetReasonCard()
	if not tc:IsRelateToBattle() then return end
	local atk=math.floor(tc:GetAttack()/2)
	if atk<0 then atk=0 end
	-- 执行破坏目标怪兽的操作
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 执行给对方造成伤害的操作
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
-- 判断该怪兽是否从场上被破坏
function c39823987.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 注册下个回合准备阶段触发的特殊召唤效果
function c39823987.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤效果的完整定义，包括触发条件、目标选择和操作
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(39823987,2))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c39823987.spcon)
	e1:SetTarget(c39823987.sptg)
	e1:SetOperation(c39823987.spop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 记录当前回合数，用于判断是否为下个回合
	e1:SetLabel(Duel.GetTurnCount())
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为下个回合，以触发特殊召唤效果
function c39823987.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合数不等于记录的回合数时触发效果
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 定义特殊召唤目标的过滤条件，要求是「月影龙 基利亚」且可特殊召唤
function c39823987.spfilter(c,e,tp)
	return c:IsCode(66818682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择逻辑
function c39823987.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39823987.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的特殊召唤目标
		and Duel.IsExistingTarget(c39823987.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中符合条件的特殊召唤目标
	local g=Duel.SelectTarget(tp,c39823987.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c39823987.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
