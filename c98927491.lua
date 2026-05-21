--レスキューキューロイド
-- 效果：
-- 「救援机人」＋「急救机人」
-- 这只怪兽不能作融合召唤以外的特殊召唤。自己场上存在的怪兽被战斗破坏送去墓地时，可以使那只怪兽守备表示特殊召唤。这个效果1回合只能使用1次。
function c98927491.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「救援机人」和「急救机人」
	aux.AddFusionProcCode2(c,24311595,36378213,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能进行融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 自己场上存在的怪兽被战斗破坏送去墓地时，可以使那只怪兽守备表示特殊召唤。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98927491,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(c98927491.target)
	e2:SetOperation(c98927491.activate)
	c:RegisterEffect(e2)
end
-- 过滤满足「被战斗破坏送去自己墓地且可以守备表示特殊召唤」条件的怪兽
function c98927491.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与检测，筛选出符合条件的被战斗破坏的怪兽并将其设为效果处理对象
function c98927491.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c98927491.filter,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		return g:GetCount()~=0
	end
	-- 将被战斗破坏的怪兽设置为效果处理的对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置当前连锁的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetLabelObject(),1,0,0)
end
-- 效果处理的执行函数，将作为对象的怪兽在自己场上守备表示特殊召唤
function c98927491.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
