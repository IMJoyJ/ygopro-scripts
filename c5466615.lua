--ミュートリア連鎖応動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的发动时，可以以对方场上1只效果怪兽为对象。那个场合，从自己墓地选1只「秘异三变」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
-- ②：自己的8星以上的「秘异三变」怪兽战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
function c5466615.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡的发动时，可以以对方场上1只效果怪兽为对象。那个场合，从自己墓地选1只「秘异三变」怪兽除外，作为对象的怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,5466615+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c5466615.target)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的8星以上的「秘异三变」怪兽战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
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
-- 过滤函数：筛选自己墓地中可以除外的「秘异三变」怪兽
function c5466615.tgfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①号效果的发动准备：若满足条件，玩家可选择是否在卡片发动时以对方场上1只效果怪兽为对象
function c5466615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象筛选：检查已选择的对象是否为对方场上的表侧表示效果怪兽
	if chkc then return aux.NegateEffectMonsterFilter(chkc) and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在可除外的「秘异三变」怪兽
	if Duel.IsExistingMatchingCard(c5466615.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在可作为无效对象的表侧表示效果怪兽
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否在发动这张卡时选择对方场上的怪兽为对象
		and Duel.SelectYesNo(tp,aux.Stringid(5466615,0)) then  --"是否选择对方怪兽效果无效？"
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c5466615.activate)
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择对方场上1只表侧表示效果怪兽作为效果对象
		local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁信息：预计从自己墓地除外1张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
		-- 设置连锁信息：预计使选中的1只怪兽效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- ①号效果的实际处理：除外自己墓地的「秘异三变」怪兽，并使作为对象的怪兽效果直到回合结束时无效
function c5466615.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只「秘异三变」怪兽
	local g=Duel.SelectMatchingCard(tp,c5466615.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若成功将选中的怪兽表侧表示除外，则继续处理后续效果
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		-- 获取发动的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 使与该怪兽相关的连锁中已发动的效果无效化
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
end
-- ②号效果的发动条件：自己的8星以上的「秘异三变」怪兽战斗破坏对方怪兽时
function c5466615.drcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsControler(tp)
		and rc:IsFaceup() and rc:IsSetCard(0x157) and rc:IsLevelAbove(8)
end
-- ②号效果的发动准备：检查是否能抽卡，并设置抽卡连锁信息
function c5466615.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置连锁信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②号效果的实际处理：执行抽卡
function c5466615.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡效果的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
