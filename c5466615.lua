--ミュートリア連鎖応動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的发动时，可以以对方场上1只效果怪兽为对象。那个场合，从自己墓地选1只「秘异三变」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
-- ②：自己的8星以上的「秘异三变」怪兽战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
function c5466615.initial_effect(c)
	-- ①：这张卡的发动时，可以以对方场上1只效果怪兽为对象。那个场合，从自己墓地选1只「秘异三变」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,5466615+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c5466615.target)
	c:RegisterEffect(e1)
	-- ②：自己的8星以上的「秘异三变」怪兽战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5466615,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,5466616)
	e3:SetCondition(c5466615.drcon)
	e3:SetTarget(c5466615.drtg)
	e3:SetOperation(c5466615.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己墓地中可被除外的「秘异三变」怪兽
function c5466615.tgfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 发动时的对象处理：先确认墓地有「秘异三变」怪兽且对方场上有可无效的效果怪兽，询问玩家是否适用无效效果；若选择是，则以对方场上1只效果怪兽为对象，并设置除外和无效的操作信息；否则本次发动作为空效果处理
function c5466615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取对象判定：检查目标是否为对方场上主要怪兽区中表侧表示、可被无效的效果怪兽
	if chkc then return aux.NegateEffectMonsterFilter(chkc) and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1只可被除外的「秘异三变」怪兽
	if Duel.IsExistingMatchingCard(c5466615.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上主要怪兽区是否存在至少1只可作为对象、可被无效的效果怪兽
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择将对方怪兽的效果无效，选择是则进入取对象处理
		and Duel.SelectYesNo(tp,aux.Stringid(5466615,0)) then  --"是否选择对方怪兽效果无效？"
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c5466615.activate)
		-- 向玩家发送选择提示消息「请选择要无效的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择对方场上1只可被无效的效果怪兽作为效果对象
		local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息：将从自己墓地除外1张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
		-- 设置操作信息：将作为对象的1只怪兽的效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 效果处理：从自己墓地选1只「秘异三变」怪兽除外，成功除外后若作为对象的怪兽仍与效果关联且表侧表示，则使其关联连锁无效，并注册两个直到回合结束时使其效果无效的状态效果
function c5466615.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择提示消息「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只可被除外的「秘异三变」怪兽
	local g=Duel.SelectMatchingCard(tp,c5466615.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若成功选出卡片并将其表侧表示除外（除外数量大于0）则继续后续无效处理
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 取得本次连锁的对象卡（即要无效的对方怪兽）
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 使与对象怪兽相关的连锁全部无效（怪兽变为里侧等情况时重置）
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的怪兽的效果直到回合结束时无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 作为对象的怪兽的效果直到回合结束时无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 发动条件：战斗破坏对方怪兽的怪兽为自己场上表侧表示的8星以上的「秘异三变」怪兽
function c5466615.drcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsControler(tp)
		and rc:IsFaceup() and rc:IsSetCard(0x157) and rc:IsLevelAbove(8)
end
-- 对象设置：确认自己可以抽1张卡，将对象玩家设为自己、对象参数设为1，并设置抽1张卡的操作信息
function c5466615.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取出对象玩家和抽卡数量，让玩家从卡组抽1张卡
function c5466615.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象玩家和对象参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因从卡组抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
