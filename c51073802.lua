--マジェスペクター・ポーキュパイン
-- 效果：
-- ←2 【灵摆】 2→
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，自己场上有「威风妖怪」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以自己墓地1张「威风妖怪」魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ③：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
local s,id,o=GetID()
-- 该函数为「威风妖怪·山荒」的效果注册入口：先为灵摆怪兽赋予灵摆召唤/灵摆卡发动属性；再注册③的永续抗性效果（不会成为对方效果对象、不会被对方效果破坏）；随后注册①的手卡二速特殊召唤效果，以及②的召唤·特殊召唤成功时盖放墓地「威风妖怪」魔法卡的效果，并用克隆效果使②在通常召唤和特殊召唤成功时都能触发。
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其能够进行灵摆召唤，并作为灵摆刻度卡发动。
	aux.EnablePendulumAttribute(c)
	-- ③：只要这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置“不能成为效果对象”的判定函数：仅当效果的发动者是这张卡的控制者的对手时，该效果不能选择这张卡为对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置“不会被效果破坏”的判定函数：仅当效果的发动者是这张卡的控制者的对手时，该效果不能破坏这张卡。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ①：自己·对方的主要阶段，自己场上有「威风妖怪」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ②：这张卡召唤·特殊召唤的场合，以自己墓地1张「威风妖怪」魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"盖放魔法"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,id+o)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断怪兽是否为表侧表示，且具有「威风妖怪」字段。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd0)
end
-- ①效果的发动条件：当前阶段为主要阶段1或主要阶段2，且自己场上存在至少1只表侧表示的「威风妖怪」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回条件判断结果：当前阶段为主要阶段1或主要阶段2，且自己怪兽区域存在表侧表示的「威风妖怪」怪兽。
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动目标检查：确认自己主要怪兽区有空位，并且这张卡自身能够被特殊召唤（不无视召唤条件和苏生限制）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动合法性检查（chk==0）时，首先确认主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记特殊召唤的操作信息：预计将这张卡特殊召唤，数量为1，用于连锁处理和后续效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与所发动的效果保持关联，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡在手牌且与效果仍有关联后，将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 墓地候选过滤函数：选择自己墓地中具有「威风妖怪」字段、可盖放且为魔法卡的卡。
function s.filter(c)
	return c:IsSetCard(0xd0) and c:IsSSetable() and c:IsType(TYPE_SPELL)
end
-- ②效果的发动目标选择：确认墓地存在至少1张符合条件的「威风妖怪」魔法卡，提示玩家选择1张作为对象，并登记该卡离开墓地的操作信息。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动合法性检查（chk==0）时，确认墓地有至少1张满足条件的「威风妖怪」魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要盖放的卡”的提示信息，用于后续选择卡片的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张符合条件的「威风妖怪」魔法卡，并将其设为当前连锁的取对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记对象卡将离开墓地的操作信息，用于「王家长眠之谷」等涉及墓地移动的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果处理：取得连锁的对象卡，若该卡仍与当前连锁关联，则将其盖放到自己场上。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所选择的第一个对象卡，即墓地中的「威风妖怪」魔法卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前连锁相关后，将其在自己的魔法与陷阱区域盖放。
	if tc:IsRelateToChain() then Duel.SSet(tp,tc) end
end
