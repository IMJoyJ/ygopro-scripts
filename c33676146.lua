--エスケープ・ゴート
-- 效果：
-- ①：衍生物以外的自己场上的怪兽为对象的效果由对方发动时，把自己场上1只怪兽解放才能发动。在自己场上把1只「逃羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。
-- ②：衍生物以外的自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只衍生物破坏。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使卡可以被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：衍生物以外的自己场上的怪兽为对象的效果由对方发动时，把自己场上1只怪兽解放才能发动。在自己场上把1只「逃羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.tkcon)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ②：衍生物以外的自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只衍生物破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	-- 设置代替破坏效果的目标过滤函数，用于判断是否可以进行代替破坏
	e3:SetValue(aux.TargetBoolFunction(s.filter,e3))
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否为非衍生物且在自己场上
function s.tfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 效果发动条件判断，判断是否为对方发动的有对象效果且目标包含非衍生物
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.tfilter,1,nil,tp)
end
-- 过滤函数，用于判断是否可以解放该怪兽
function s.cfilter(c,tp)
	-- 检查该怪兽是否可以被解放（即其所在区域是否有空位）
	return Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动的费用支付函数，检查是否可以解放满足条件的怪兽并选择支付
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付解放费用
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 执行怪兽的解放操作
	Duel.Release(g,REASON_COST)
end
-- 效果的发动目标设定函数，判断是否可以特殊召唤衍生物
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已经支付过费用或场上是否有空位
	if chk==0 then return e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果发动的处理函数，判断是否可以特殊召唤衍生物
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
	-- 创建一个逃羊衍生物
	local tk=Duel.CreateToken(tp,id+o)
	-- 将创建的衍生物特殊召唤到场上
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤函数，用于判断是否为非衍生物且被战斗或效果破坏
function s.filter(c,e)
	local tp=e:GetHandlerPlayer()
	return not c:IsType(TYPE_TOKEN) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
end
-- 过滤函数，用于判断是否为衍生物且可以被破坏
function s.rfilter(c,e)
	return c:IsType(TYPE_TOKEN) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的目标选择函数，判断是否可以进行代替破坏并选择衍生物
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以进行代替破坏
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的衍生物
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的衍生物作为代替破坏对象
		local tc=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e):GetFirst()
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数，执行代替破坏操作
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 执行代替破坏操作，将选中的衍生物破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
