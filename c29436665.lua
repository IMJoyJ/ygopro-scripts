--黒魔導の執行官
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「黑魔术师」解放的场合才能特殊召唤。只要这张卡在场上表侧表示存在，每次自己或者对方把通常魔法卡发动，给与对方基本分1000分伤害。
function c29436665.initial_effect(c)
	-- 记录该卡具有「黑魔术师」这张卡的卡片密码
	aux.AddCodeList(c,46986414)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「黑魔术师」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c29436665.spcon)
	e2:SetTarget(c29436665.sptg)
	e2:SetOperation(c29436665.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把通常魔法卡发动，给与对方基本分1000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e3:SetOperation(aux.chainreg)
	c:RegisterEffect(e3)
	-- 每次自己或者对方把通常魔法卡发动，给与对方基本分1000分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29436665,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c29436665.dmgcon)
	e4:SetOperation(c29436665.dmgop)
	c:RegisterEffect(e4)
end
-- 用于判断是否满足特殊召唤条件的过滤器函数，检查目标卡是否为「黑魔术师」且有可用怪兽区
function c29436665.rfilter(c,tp)
	return c:IsCode(46986414)
		-- 检查目标卡是否拥有可用的怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断特殊召唤条件是否满足，检查是否有满足条件的「黑魔术师」可解放
function c29436665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足rfilter条件的可解放卡
	return Duel.CheckReleaseGroupEx(tp,c29436665.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤的目标，选择要解放的「黑魔术师」
function c29436665.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的「黑魔术师」卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c29436665.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的操作，将选定的卡进行解放
function c29436665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡进行解放操作
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断是否触发伤害效果，检查发动的是否为通常魔法卡且该卡在连锁中
function c29436665.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetActiveType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 执行伤害效果，给与对方基本分1000分伤害
function c29436665.dmgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方基本分1000分伤害
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
