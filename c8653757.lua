--フォトン・リタデイション
-- 效果：
-- ①：从卡组选1张「光子」永续魔法·永续陷阱卡或者「银河」永续魔法·永续陷阱卡加入手卡或在自己场上表侧表示放置。
-- ②：盖放的这张卡在对方回合被对方的效果破坏的场合，若自己场上有着「银河眼光子龙」或者有「银河眼光子龙」在作为超量素材中的超量怪兽存在则能发动。变成这个回合的结束阶段。
function c8653757.initial_effect(c)
	-- ①：从卡组选1张「光子」永续魔法·永续陷阱卡或者「银河」永续魔法·永续陷阱卡加入手卡或在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8653757,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c8653757.target)
	e1:SetOperation(c8653757.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡在对方回合被对方的效果破坏的场合，若自己场上有着「银河眼光子龙」或者有「银河眼光子龙」在作为超量素材中的超量怪兽存在则能发动。变成这个回合的结束阶段。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCondition(c8653757.etcon)
	e2:SetOperation(c8653757.etop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「光子」或「银河」永续魔法·永续陷阱卡，且满足能加入手卡或在场上表侧表示放置的条件
function c8653757.filter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x55,0x7b)
		-- 检查卡片是否可以加入手卡，或者在魔法与陷阱区域有空位、不被禁止且在场上唯一存在时可以放置
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden() and c:CheckUniqueOnField(tp)))
end
-- 效果①的发动准备
function c8653757.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8653757.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果①的处理（从卡组选择卡片加入手卡或在场上表侧表示放置）
function c8653757.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local tc=Duel.SelectMatchingCard(tp,c8653757.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 如果卡片能加入手卡，且在无法放置到场上或玩家选择加入手卡时，执行加入手卡的分支
		if tc:IsAbleToHand() and (Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsForbidden() or not tc:CheckUniqueOnField(tp) or Duel.SelectOption(tp,1190,aux.Stringid(8653757,1))==0) then  --"表侧表示放置"
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡在自己的魔法与陷阱区域表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end
-- 过滤场上表侧表示的「银河眼光子龙」，或者拥有「银河眼光子龙」作为超量素材的超量怪兽
function c8653757.cfilter(c)
	return c:IsFaceup() and (c:IsCode(93717133) or (c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,93717133)))
end
-- 效果②的发动条件判断
function c8653757.etcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前是否为对方回合，且这张卡在自己场上因对方的效果被破坏
	return Duel.GetTurnPlayer()~=tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
		and c:GetReasonPlayer()==1-tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己场上是否存在「银河眼光子龙」或以其为素材的超量怪兽
		and Duel.IsExistingMatchingCard(c8653757.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的处理（跳过对方回合的各个阶段，直接变成结束阶段）
function c8653757.etop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方回合的抽卡阶段
	Duel.SkipPhase(1-tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	-- 跳过对方回合的准备阶段
	Duel.SkipPhase(1-tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	-- 跳过对方回合的主要阶段1
	Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过对方回合的战斗阶段（并跳过战斗阶段的结束步骤）
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过对方回合的主要阶段2
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能进行战斗阶段的玩家效果，确保直接进入结束阶段
	Duel.RegisterEffect(e1,tp)
end
