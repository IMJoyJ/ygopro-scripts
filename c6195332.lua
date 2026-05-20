--超神星輝士 セイクリッド・トレミスΩ７
-- 效果：
-- 7星怪兽×3
-- 「超神星辉士 星圣神龙 托勒密星团Ω7」在自己主要阶段2有1次也能在自己场上的「星骑士」、「星圣」超量怪兽上面重叠来超量召唤。
-- ①：这张卡只要自己的墓地·除外状态的「星骑士」怪兽是7种类以上，攻击力·守备力上升2700，不受对方发动的效果影响。
-- ②：自己·对方回合1次，把这张卡的超量素材任意数量取除，以那个数量的对方场上的怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片效果：XYZ召唤手续、复活限制、不受对方发动效果影响、攻守上升、以及去除素材让对方场上怪兽回到卡组的即时诱发效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在「星骑士」「星圣」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- 不受对方发动的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.efcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 攻击力·守备力上升2700
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCondition(s.efcon)
	e2:SetValue(2700)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 自己·对方回合1次，把这张卡的超量素材任意数量取除，以那个数量的对方场上的怪兽为对象才能发动。那些怪兽回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回卡组效果"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
-- 过滤用于重叠超量召唤的怪兽：场上表侧表示的「星骑士」或「星圣」超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9c,0x53) and c:IsXyzType(TYPE_XYZ)
end
-- 重叠超量召唤的操作与条件判定：检查是否在自己的主要阶段2且本回合未使用过该方式召唤，并注册回合内已使用的标记
function s.xyzop(e,tp,chk)
	-- 检查重叠超量召唤的条件：本回合未以此法特殊召唤过、当前是自己的回合且处于主要阶段2
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN2 end
	-- 为玩家注册本回合已进行过该重叠超量召唤的标记（誓约效果，持续到回合结束）
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤墓地或除外状态的「星骑士」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x9c) and c:IsType(TYPE_MONSTER)
end
-- 判定抗性与攻守上升效果的启用条件：自己墓地·除外状态的「星骑士」怪兽是7种类以上
function s.efcon(e)
	-- 获取自己墓地及除外状态的所有「星骑士」怪兽
	local ct=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	return ct:GetClassCount(Card.GetCode)>=7
end
-- 免疫效果过滤器：不受对方发动的效果影响
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 回卡组效果的发动准备与目标选择：检查并去除任意数量的超量素材，选择相同数量的对方场上怪兽作为对象，并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:IsCostChecked() then
			return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
				-- 检查对方场上是否存在可以回到卡组的怪兽
				and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil)
		else return false end
	end
	-- 获取对方场上可以回到卡组的怪兽的最大数量
	local rt=Duel.GetTargetCount(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择与去除素材数量相同的对方场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 设置当前连锁的操作信息：将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
-- 过滤仍与当前连锁有关联且为怪兽的卡片
function s.tdfilter(c)
	return c:IsRelateToChain() and c:IsType(TYPE_MONSTER)
end
-- 回卡组效果的执行：获取并过滤目标怪兽，将其送回持有者卡组并洗牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(s.tdfilter,nil)
	if #rg>0 then
		-- 将目标怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
