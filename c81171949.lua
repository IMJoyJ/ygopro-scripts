--ジャックポット7
-- 效果：
-- 这张卡回到卡组洗切。此外，这张卡被对方的卡的效果送去墓地时，这张卡从游戏中除外。这个效果从游戏中除外的自己的「头奖壶7」3张齐集时，自己决斗胜利。
function c81171949.initial_effect(c)
	-- 这张卡回到卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c81171949.activate)
	c:RegisterEffect(e1)
	-- 此外，这张卡被对方的卡的效果送去墓地时，这张卡从游戏中除外。这个效果从游戏中除外的自己的「头奖壶7」3张齐集时，自己决斗胜利。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81171949,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c81171949.rmcon)
	e2:SetTarget(c81171949.rmtg)
	e2:SetOperation(c81171949.rmop)
	c:RegisterEffect(e2)
end
-- 魔法卡发动时的效果处理：若此卡在场则将其回到持有者卡组并洗牌
function c81171949.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送回持有者卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
-- 触发条件：此卡因对方卡片的效果送去墓地（且不是因为回到墓地）
function c81171949.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and bit.band(r,REASON_RETURN)==0
end
-- 效果发动时的目标确认：此效果为必发效果，在发动时设置将自身从墓地除外的操作信息
function c81171949.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将墓地的此卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 过滤条件：卡名为「头奖壶7」且带有因该效果除外的标记
function c81171949.filter(c)
	return c:IsCode(81171949) and c:GetFlagEffect(81171949)~=0
end
-- 效果处理：将此卡除外并给其注册因该效果除外的标记，若此时除外区已集齐3张带有该标记的「头奖壶7」，则自己决斗胜利
function c81171949.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其表侧表示除外，并判断是否成功除外
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		c:RegisterFlagEffect(81171949,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 检查自己的除外区是否存在至少3张因该效果除外的「头奖壶7」
		if Duel.IsExistingMatchingCard(c81171949.filter,tp,LOCATION_REMOVED,0,3,nil) then
			local WIN_REASON_JACKPOT7=0x19
			-- 判定当前玩家以「头奖壶7」的效果决斗胜利
			Duel.Win(tp,WIN_REASON_JACKPOT7)
		end
	end
end
