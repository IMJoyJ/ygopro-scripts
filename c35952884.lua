--シューティング・クェーサー・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的攻击。
-- ②：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ③：表侧表示的这张卡从场上离开时才能发动。从额外卡组把1只「流星龙」特殊召唤。
function c35952884.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和至少2只调整以外的同调怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过同调召唤方式
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c35952884.valcheck)
	c:RegisterEffect(e3)
	-- ②：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35952884,0))  --"效果无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c35952884.discon)
	e3:SetTarget(c35952884.distg)
	e3:SetOperation(c35952884.disop)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡从场上离开时才能发动。从额外卡组把1只「流星龙」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35952884,1))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c35952884.sumcon)
	e4:SetTarget(c35952884.sumtg)
	e4:SetOperation(c35952884.sumop)
	c:RegisterEffect(e4)
end
c35952884.material_type=TYPE_SYNCHRO
c35952884.cosmic_quasar_dragon_summon=true
-- 检查同调素材数量并为该卡增加额外攻击次数
function c35952884.valcheck(e,c)
	local ct=c:GetMaterialCount()-1
	if ct>1 then
		-- 增加该卡在同1次战斗阶段中可进行的攻击次数
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	end
end
-- 判断连锁是否可以被无效
function c35952884.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 该卡未在战斗阶段被破坏且连锁可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理时的操作信息，包括使发动无效和破坏目标卡片
function c35952884.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理连锁无效并破坏目标卡片的效果
function c35952884.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效且目标卡片存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断该卡是否从场上离开且处于表侧表示状态
function c35952884.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足条件的「流星龙」卡片
function c35952884.filter(c,e,tp)
	-- 卡片为「流星龙」且可特殊召唤且场上存在召唤空间
	return c:IsCode(24696097) and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤效果的目标和操作信息
function c35952884.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的「流星龙」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c35952884.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理特殊召唤效果
function c35952884.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「流星龙」卡片
	local tg=Duel.GetFirstMatchingCard(c35952884.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP)
	end
end
