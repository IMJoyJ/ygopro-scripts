--B・F・W
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：1回合最多2次，自己场上有「蜂军」怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。比那只怪兽攻击力低的1只「蜂军」怪兽从卡组加入手卡。
-- ②：1回合1次，以自己场上1只持有等级的昆虫族怪兽为对象才能发动。这个回合，自己把作为对象的怪兽作为同调素材的场合，可以当作调整使用。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括卡片发动、①效果（检索）、②效果（当作调整）以及召唤/特殊召唤的延迟事件注册。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：1回合最多2次，自己场上有「蜂军」怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。比那只怪兽攻击力低的1只「蜂军」怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只持有等级的昆虫族怪兽为对象才能发动。这个回合，自己把作为对象的怪兽作为同调素材的场合，可以当作调整使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.tntg)
	e3:SetOperation(s.tnop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	-- 注册通常召唤成功的合并延迟事件，用于处理多只怪兽同时召唤时仅触发一次效果。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SUMMON_SUCCESS,g)
	-- 注册特殊召唤成功的合并延迟事件，用于处理多只怪兽同时特殊召唤时仅触发一次效果。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS,g)
end
-- 过滤满足作为①效果对象的「蜂军」怪兽：必须在自己场上表侧表示存在，且卡组中存在攻击力比其低的「蜂军」怪兽。
function s.tgfilter(c,e,tp,chk)
	return c:IsSetCard(0x12f) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp) and c:IsCanBeEffectTarget(e) and c:IsAttackAbove(1)
		-- 检查卡组中是否存在攻击力比该怪兽低的、可检索的「蜂军」怪兽（若仅是检测合法对象则跳过此检查）。
		and (chk or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),tp))
end
-- 过滤满足检索条件的「蜂军」怪兽：攻击力必须低于指定数值，且能加入手卡。
function s.thfilter(c,atk,tp)
	return c:IsSetCard(0x12f) and c:IsAttackBelow(atk-1) and c:IsAbleToHand()
end
-- ①效果的发动准备与对象选择：从触发事件的怪兽中选择1只符合条件的「蜂军」怪兽作为对象，并声明检索操作。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.tgfilter(chkc,e,tp,true) end
	local g=eg:Filter(s.tgfilter,nil,e,tp,false)
	if chk==0 then return g:GetCount()>0 end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	if g:GetCount()==1 then
		-- 当只有1只符合条件的怪兽时，直接将其设为效果的对象。
		Duel.SetTargetCard(g:GetFirst())
	else
		-- 提示玩家选择作为效果对象的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local tc=g:Select(tp,1,1,nil)
		-- 将玩家选择的怪兽设为效果的对象。
		Duel.SetTargetCard(tc)
	end
	-- 设置效果处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：检查对象怪兽是否仍在场上表侧表示，若是，则从卡组选择1只攻击力更低的「蜂军」怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果在发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1只攻击力低于对象怪兽的「蜂军」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttack(),tp)
		if sg:GetCount()>0 then
			-- 将选择的怪兽因效果加入手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤满足②效果对象的怪兽：自己场上表侧表示、持有等级且非调整的昆虫族怪兽。
function s.tfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and not c:IsType(TYPE_TUNER)
		and c:IsLevelAbove(1)
end
-- ②效果的发动准备与对象选择：选择自己场上1只持有等级的昆虫族怪兽作为对象。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 检查自己场上是否存在符合条件的、可作为对象的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的昆虫族怪兽作为效果对象。
	Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的实际处理：对作为对象的怪兽适用“作为同调素材的场合，可以当作调整使用”的效果。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果在发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，自己把作为对象的怪兽作为同调素材的场合，可以当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TUNER)
		e1:SetValue(s.tunerval)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 限制该怪兽仅在作为自己（效果持有者）的同调素材时，才能当作调整使用。
function s.tunerval(e,sc)
	return sc:IsControler(e:GetHandlerPlayer())
end
