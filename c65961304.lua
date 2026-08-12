--キラーチューン B２B
-- 效果：
-- 调整＋同调怪兽1只以上
-- 这个卡名的③的效果1回合可以使用最多2次。
-- ①：对方场上的怪兽的等级上升2星。
-- ②：自己的调整在同1次的战斗阶段中可以作2次攻击。
-- ③：对方把怪兽的效果发动时，以10星以外的自己的墓地·除外状态的1只调整为对象才能发动。那只怪兽加入手卡或特殊召唤。那之后，可以进行1只同调怪兽的同调召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、素材检查、等级上升、追加攻击和对方发动效果时回收/特召调整并同调的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：调整＋同调怪兽1只以上。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
	-- 调整＋同调怪兽1只以上
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- ①：对方场上的怪兽的等级上升2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(2)
	c:RegisterEffect(e1)
	-- ②：自己的调整在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：对方把怪兽的效果发动时，以10星以外的自己的墓地·除外状态的1只调整为对象才能发动。那只怪兽加入手卡或特殊召唤。那之后，可以进行1只同调怪兽的同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"加入手卡或特殊召唤"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(2,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 检查同调素材中是否包含2只以上的调整怪兽，若是则给自身注册特定效果。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整＋同调怪兽1只以上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤属于调整怪兽的卡，作为追加攻击效果的对象。
function s.atktg(e,c)
	return c:IsType(TYPE_TUNER)
end
-- 确认发动效果的玩家为对方且发动的是怪兽效果，作为效果③的发动条件。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己墓地或除外状态的、10星以外的调整怪兽，且该卡必须能加入手卡或在怪兽区域有空位时能特殊召唤。
function s.filter(c,e,tp)
	-- 获取玩家场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsType(TYPE_TUNER) and not c:IsLevel(10) and c:IsFaceupEx()
		and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果③的靶向与发动准备函数，确认是否存在合法目标，进行取对象操作，并设置加入手卡和特殊召唤的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己墓地或除外状态是否存在至少1只满足条件的调整怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家选择1只满足条件的调整怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置将目标卡片加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	-- 设置将目标卡片特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
-- 效果③的处理函数，将选择的怪兽加入手卡或特殊召唤，之后可选择进行同调召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与连锁相关，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		local b1=tc:IsAbleToHand()
		-- 检查对象怪兽是否可以特殊召唤，且自己场上是否有可用的怪兽区域。
		local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 让玩家在“加入手卡”和“特殊召唤”中选择一个可行的操作。
		local op=aux.SelectFromOptions(tp,
			{b1,1190,1},
			{b2,1152,2})
		local res=false
		if op==1 then
			-- 将对象怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
			res=tc:IsLocation(LOCATION_HAND)
		elseif op==2 then
			-- 将对象怪兽以表侧表示特殊召唤到自己场上，并记录是否特殊召唤成功。
			res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 若无法特殊召唤则根据规则将该卡送去墓地。
			Duel.SendtoGrave(tc,REASON_RULE)
		end
		if res then
			-- 获取额外卡组中当前可以进行同调召唤的同调怪兽组合。
			local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
			-- 若存在可同调召唤的怪兽，询问玩家是否进行同调召唤。
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否同调召唤？"
				-- 中断当前效果处理，使后续的同调召唤不与回收/特召同时处理。
				Duel.BreakEffect()
				-- 提示玩家选择要进行同调召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 对选定的怪兽进行同调召唤。
				Duel.SynchroSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
end
