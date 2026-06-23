--青眼の光龍
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「青眼究极龙」解放的场合才能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的龙族怪兽数量×300。
-- ②：这张卡为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c53347303.initial_effect(c)
	-- 记录此卡具有「青眼究极龙」的卡片密码，用于特殊召唤条件判断
	aux.AddCodeList(c,23995346)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只「青眼究极龙」解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被通常召唤，必须满足特定条件才能特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 特殊召唤时需解放一只「青眼究极龙」，且解放区域需有空位
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c53347303.spcon)
	e2:SetTarget(c53347303.sptg)
	e2:SetOperation(c53347303.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己墓地的龙族怪兽数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c53347303.val)
	c:RegisterEffect(e3)
	-- ②：这张卡为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53347303,0))  --"以这张卡为对象的效果无效化。"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c53347303.discon)
	e4:SetTarget(c53347303.distg)
	e4:SetOperation(c53347303.disop)
	c:RegisterEffect(e4)
end
-- 筛选场上可解放的「青眼究极龙」卡片，确保其所在区域有空位
function c53347303.spfilter(c,tp)
	-- 判断目标是否为「青眼究极龙」且其所在区域有可用空间
	return c:IsCode(23995346) and Duel.GetMZoneCount(tp,c)>0
end
-- 检查是否有满足条件的「青眼究极龙」可作为解放对象
function c53347303.spcon(e,c)
	if c==nil then return true end
	-- 调用CheckReleaseGroupEx函数检测是否存在符合条件的解放对象
	return Duel.CheckReleaseGroupEx(c:GetControler(),c53347303.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 选择并标记要解放的「青眼究极龙」卡片
function c53347303.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有可解放的卡片组，并从中筛选出「青眼究极龙」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c53347303.spfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c53347303.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际将标记的卡片从场上解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 计算墓地中龙族怪兽数量并乘以300作为攻击力加成
function c53347303.val(e,c)
	-- 获取自己墓地中所有龙族怪兽的数量，并乘以300作为攻击力提升值
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_DRAGON)*300
end
-- 判断连锁效果是否可以被无效化，且目标为本卡
function c53347303.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的发动位置和目标卡片组
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(c) then return false end
	-- 确认该连锁效果可被无效且不是从牌组发动
	return Duel.IsChainDisablable(ev) and loc~=LOCATION_DECK
end
-- 设置操作信息，表示将要使效果无效
function c53347303.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将要无效的效果类别为CATEGORY_DISABLE
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 执行效果无效化操作
function c53347303.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用NegateEffect函数使当前连锁效果无效
	Duel.NegateEffect(ev)
end
