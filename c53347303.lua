--青眼の光龍
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「青眼究极龙」解放的场合才能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的龙族怪兽数量×300。
-- ②：这张卡为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c53347303.initial_effect(c)
	-- 将卡名「青眼究极龙」(23995346) 登记到这张卡的代码列表中，表明本卡效果文本中记载了该卡名。
	aux.AddCodeList(c,23995346)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定值为 false，使这张卡不能被一般效果特殊召唤，只能通过自身规则特殊召唤手续出场。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上1只「青眼究极龙」解放的场合才能特殊召唤。
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
-- 定义特殊召唤解放素材的筛选函数：候选卡必须是「青眼究极龙」，且解放它后自己的怪兽区仍有空位可供特殊召唤。
function c53347303.spfilter(c,tp)
	-- 判断候选卡是否为「青眼究极龙」，并且该卡被解放后自己场上仍留有怪兽区空格。
	return c:IsCode(23995346) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的条件判断：当需要召唤的是这张卡时，检查其控制者场上是否存在可解放的满足条件的「青眼究极龙」。
function c53347303.spcon(e,c)
	if c==nil then return true end
	-- 检查控制者场上是否存在至少1只满足 spfilter 条件、可作为特殊召唤解放素材的「青眼究极龙」。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c53347303.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 特殊召唤手续的目标选择：让玩家从可解放的「青眼究极龙」中选择1只，并将选择结果暂存在效果的 LabelObject 中，供后续解放使用。
function c53347303.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得当前玩家可解放的卡片组，并筛选出其中满足条件（是「青眼究极龙」且解放后有空格）的卡片作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c53347303.spfilter,nil,tp)
	-- 给玩家显示「请选择要解放的卡」的提示信息，用于解放素材选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：取出之前选中的「青眼究极龙」，完成解放动作。
function c53347303.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「青眼究极龙」以特殊召唤为理由解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 计算这张卡的攻击力上升量：己方墓地龙族怪兽数量 × 300。
function c53347303.val(e,c)
	-- 统计自己墓地中所有龙族怪兽的数量，并乘以 300 作为攻击力上升的数值。
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_DRAGON)*300
end
-- ②效果的发动条件：这张卡仍在场上且未被战斗破坏确定；正在发动的效果是取对象效果且对象包含这张卡；该效果可以被无效且不是从卡组发动。
function c53347303.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁效果的发生位置和对象卡组，用于确认该效果是否以这张卡为对象。
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(c) then return false end
	-- 确认当前连锁效果可被无效，并且其发动位置不是卡组。
	return Duel.IsChainDisablable(ev) and loc~=LOCATION_DECK
end
-- ②效果的发动时目标处理：chk==0 时直接允许发动；通过操作信息声明要无效当前连锁效果。
function c53347303.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次处理登记为无效1个效果，即正在连锁的那个效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的实际处理：执行将当前连锁效果无效化的操作。
function c53347303.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁编号为 ev 的效果无效，即把以这张卡为对象的效果无效。
	Duel.NegateEffect(ev)
end
