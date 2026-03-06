--ゴーティスの死棘グオグリム
-- 效果：
-- 鱼族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽除外。
-- ②：对方准备阶段才能发动。这张卡除外。那之后，若作为这张卡的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续并注册两个触发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：需要1只鱼族调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FISH),aux.NonTuner(nil),1)
	-- 效果①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 效果②：对方准备阶段才能发动。这张卡除外。那之后，若作为这张卡的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动时的取对象处理，判断对方怪兽是否可以除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToRemove() end
	-- 设置效果①的处理对象为对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 效果①的发动处理，将对方怪兽除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 将对方怪兽以效果原因除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件，判断是否为对方准备阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的发动时的取对象处理，判断自身是否可以除外
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	-- 设置效果②的处理对象为自身
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 过滤墓地中的同调素材怪兽，判断是否满足特殊召唤条件
function s.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动处理，将自身除外并检索墓地中的同调素材怪兽进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetMaterial()
	local ct=#mg
	-- 将自身以效果原因除外并确认是否在除外区且为同调召唤
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED) and c:GetSummonType()==SUMMON_TYPE_SYNCHRO
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断墓地中的同调素材怪兽是否全部满足特殊召唤条件并询问玩家是否发动
		and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,c)==ct and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把同调素材怪兽特殊召唤？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 遍历同调素材怪兽组
		for tc in aux.Next(mg) do
			-- 特殊召唤一张同调素材怪兽
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 为特殊召唤的怪兽设置离开场时回到除外区的效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				tc:RegisterEffect(e1,true)
			end
		end
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
