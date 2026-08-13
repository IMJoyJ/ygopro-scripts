--百鬼羅刹大暴走
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的主要阶段才能发动。只用自己场上的「哥布林」怪兽为素材进行超量召唤。
-- ②：自己场上有「哥布林」超量怪兽存在的场合，以场上1只效果怪兽为对象才能发动。场上1个超量素材取除，作为对象的怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册三个效果：e0为魔陷发动所需的基础效果（允许卡发动）；e1实现①效果（主要阶段用自己场上哥布林怪兽进行超量召唤）；e2实现②效果（自己场上有哥布林超量怪兽时，取对象去除场上1个超量素材并无效对象怪兽）；e1与e2通过SetCountLimit(1,id)共享1回合1次的发动次数。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己·对方的主要阶段才能发动。只用自己场上的「哥布林」怪兽为素材进行超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"超量召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「哥布林」超量怪兽存在的场合，以场上1只效果怪兽为对象才能发动。场上1个超量素材取除，作为对象的怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示、卡名含有「哥布林」（0xac）、且不是衍生物的怪兽，作为①超量召唤的素材候选。
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and not c:IsType(TYPE_TOKEN)
end
-- 筛选额外卡组中能用候选素材组mg进行超量召唤的超量怪兽。
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(mg)
end
-- ①效果的发动条件：当前阶段是主要阶段1或主要阶段2（自己·对方的主要阶段才能发动）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果发动时的目标检查与操作信息设定：检查是否有可用素材组及对应超量怪兽；若有，将操作信息登记为从额外卡组特殊召唤1只怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有符合条件的「哥布林」怪兽，作为超量召唤的素材候选组。
		local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在1只以上能用上述素材组进行超量召唤的超量怪兽。
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	-- 设置本连锁的操作信息：预定从额外卡组特殊召唤1只怪兽（此时对象数量为1，归属玩家tp，位置为额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理时：重新获取素材组和可超量召唤的额外怪兽组，让玩家选择1只超量怪兽，然后用素材组中的1~6只怪兽进行超量召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取自己场上符合条件的「哥布林」怪兽组作为素材。
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中能够以当前素材组进行超量召唤的怪兽组。
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 向操作玩家显示选择提示，要求选择要特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 用g中的1~6只「哥布林」怪兽作为超量素材，将选中的xyz怪兽进行超量召唤。
		Duel.XyzSummon(tp,xyz,g,1,6)
	end
end
-- 筛选自己场上表侧表示且为「哥布林」超量怪兽，用于②效果的发动条件判定。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动条件：自己场上有表侧表示的「哥布林」超量怪兽存在。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在1只以上符合s.filter条件的「哥布林」超量怪兽。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动时的目标检查与选择：确认可以选择场上1只效果怪兽为对象，且自己场上能移除1个超量素材；然后选择对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若在连锁处理中指定对象，则确认该卡位于怪兽区且是可被无效的表侧效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 在chk==0（发动合法性检查）时，确认场上存在可被无效的效果怪兽，并且能以效果原因移除场上1个超量素材。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	-- 向操作玩家显示选择提示，要求选择要无效的效果怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从双方怪兽区选择1只可无效的表侧效果怪兽作为本效果的对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：若对象仍表侧表示且与本效果关联，并仍可移除超量素材，则移除场上1个超量素材，并无效该对象怪兽的效果直到回合结束（包括相关连锁无效和怪兽效果无效）。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果取的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍在场上表侧表示、与本效果保持关联，且场上仍存在可移除的超量素材。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) then
		-- 以效果原因从场上移除1个超量素材（不区分我方或对方）。
		Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
		-- 将对象怪兽与当前连锁相关的效果无效化（使其效果发动及效果处理被无效）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 作为对象的怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 作为对象的怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
