--幻界突破
-- 效果：
-- ①：1回合1次，把自己场上1只龙族怪兽解放才能发动。和解放的怪兽的原本等级相同等级的1只幻龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽战斗破坏的怪兽不送去墓地回到持有者卡组。
function c16960351.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上1只龙族怪兽解放才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16960351,0))  --"「幻界突破」效果适用中"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c16960351.spcost)
	e2:SetTarget(c16960351.sptg)
	e2:SetOperation(c16960351.spop)
	c:RegisterEffect(e2)
end
-- 筛选场上可解放的龙族怪兽，要求其原本等级大于0且卡组存在相同等级的幻龙族怪兽可特殊召唤
function c16960351.rfilter(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	return lv>0 and c:IsRace(RACE_DRAGON)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在满足等级条件的幻龙族怪兽
		and Duel.IsExistingMatchingCard(c16960351.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 筛选卡组中满足等级与种族条件的幻龙族怪兽
function c16960351.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 支付解放龙族怪兽的代价，检查场上是否有符合条件的龙族怪兽可解放并进行解放操作
function c16960351.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上怪兽区域的可用空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判定是否满足解放条件，包括场上空位和可解放的龙族怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c16960351.rfilter,1,nil,e,tp,ft) end
	-- 选择1只符合条件的龙族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c16960351.rfilter,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalLevel())
	-- 执行解放操作，将选中的怪兽从场上解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果发动时的处理信息，确定将要特殊召唤的卡
function c16960351.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明将要特殊召唤1张幻龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，选择并特殊召唤幻龙族怪兽，并设置其战斗破坏后返回卡组的效果
function c16960351.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的幻龙族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足等级与种族条件的幻龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c16960351.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的幻龙族怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽战斗破坏的怪兽不送去墓地回到持有者卡组
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
