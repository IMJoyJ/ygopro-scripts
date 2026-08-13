--六世壊他化自在天
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「俱舍怒威族」怪兽为对象才能发动。和那只怪兽属性不同的1只「俱舍怒威族」怪兽从卡组守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被除外的场合，以「六世坏他化自在天」以外的除外的1张自己的「俱舍怒威族」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册①和②两个效果。①为魔法卡发动时以自己场上1只「俱舍怒威族」怪兽为对象，从卡组特殊召唤1只不同属性的「俱舍怒威族」怪兽并附加自肃；②为这张卡被除外时，以除外区1张自己的「俱舍怒威族」卡（除自身外）为对象加入手卡；两个效果各自1回合1次。
function s.initial_effect(c)
	-- ①：以自己场上1只「俱舍怒威族」怪兽为对象才能发动。和那只怪兽属性不同的1只「俱舍怒威族」怪兽从卡组守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以「六世坏他化自在天」以外的除外的1张自己的「俱舍怒威族」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 对象怪兽的筛选：要求对象是自己场上表侧表示的「俱舍怒威族」怪兽，并且卡组中存在1只满足特殊召唤条件的不同属性「俱舍怒威族」怪兽。
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x189)
		-- 确认卡组中存在至少1只与对象怪兽属性不同且可被当前效果特殊召唤的「俱舍怒威族」怪兽，作为①效果的发动前提。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
-- 特殊召唤候选的筛选：从卡组选择1只「俱舍怒威族」怪兽，要求其属性与对象怪兽不同，并且可以被当前效果以表侧守备表示特殊召唤。
function s.spfilter(c,e,tp,attr)
	return not c:IsAttribute(attr) and c:IsSetCard(0x189)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果发动时的对象合法性检查：在连锁确认时，对象必须是自己场上表侧表示的「俱舍怒威族」怪兽且满足s.filter；在发动时确认自己场上有空位且存在可选择的合法对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- ①效果的发动条件之一：自己主要怪兽区域存在空位，以能够进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ①效果的发动条件之二：自己场上存在至少1只可作为对象的「俱舍怒威族」怪兽（满足s.filter）。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只满足条件的「俱舍怒威族」怪兽作为①效果的对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置①效果的操作信息：预定从卡组特殊召唤1只怪兽，用于后续时点检测和联动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若对象怪兽仍与效果相关、表侧表示且自己场上有空位，则从卡组选择1只属性不同的「俱舍怒威族」怪兽以表侧守备表示特殊召唤；然后给己方附加直到回合结束时不能从额外卡组特殊召唤非超量怪兽的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然与效果相关联、表侧表示，并且自己场上有空位，才继续特殊召唤处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local attr=tc:GetAttribute()
		-- 向玩家发送选择要特殊召唤的卡的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选出1只满足条件的「俱舍怒威族」怪兽（与对象怪兽属性不同、可守备表示特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,attr)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。②：这张卡被除外的场合，以「六世坏他化自在天」以外的除外的1张自己的「俱舍怒威族」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使其影响己方玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃条件的判定：禁止从额外卡组特殊召唤非超量怪兽（超量怪兽不受此限制）。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果回收对象的筛选：对象必须是除外区表侧表示、不是这张卡自身、属于「俱舍怒威族」系列且能够加入手卡的卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x189) and c:IsFaceup() and c:IsAbleToHand()
end
-- ②效果发动时的对象检查与选择：确认对象为除外区中满足条件的「俱舍怒威族」卡；发动时选择1张并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	-- ②效果的发动条件：自己除外区存在至少1张满足条件的「俱舍怒威族」卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家发送选择要加入手牌的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1张满足条件的「俱舍怒威族」卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置②效果的操作信息：预定将对象卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若对象卡仍与该效果相关，则将其加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
