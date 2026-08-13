--アザミナ・アーフェス
-- 效果：
-- 这个卡名在规则上也当作「白森林」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己的场上·墓地的恶魔族·幻想魔族·魔法师族的融合·同调怪兽数量的场上的卡为对象才能发动。那些卡回到手卡。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化该卡的效果：创建①速攻魔法效果（取对象回手牌）和②墓地诱发效果（盖放自身），并分别注册到卡片上。
function s.initial_effect(c)
	-- ①：以最多有自己的场上·墓地的恶魔族·幻想魔族·魔法师族的融合·同调怪兽数量的场上的卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为表侧表示且种族为恶魔族/幻想魔族/魔法师族，且为融合/同调怪兽，用于统计①效果数量上限。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_FIEND+RACE_ILLUSION+RACE_SPELLCASTER)
		and c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- ①效果的发动准备：统计符合条件的怪兽数作为可选场上卡数上限；若场上存在可回手牌且不是本卡的卡则允许发动；选择1到上限张场上卡为对象，并登记回手牌操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上·墓地中表侧表示的恶魔族/幻想魔族/魔法师族融合·同调怪兽的数量，作为可选的场上卡数量上限。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 发动合法性判定：当数量上限大于0，且场上存在至少1张可以回手牌、又能成为对象且不是本卡的卡时，效果才能发动。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从双方场上选择1到ct张可以回手牌且不是本卡的卡作为对象，并将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 登记操作信息：本连锁将把对象卡返回手牌，对象数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：取得连锁对象，筛选出仍与该效果关联的卡，将这些卡返回持有者手牌。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果的理由将被筛选出的对象卡返回持有者手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- ②效果发动条件：本卡是为了让怪兽效果发动而被作为代价送去墓地，且该效果为已发动的怪兽效果。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果发动准备：若本卡当前可以盖放，则登记“本卡从墓地离开”的操作信息（用于王家长眠之谷等互动判定）。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 登记操作信息：声明本卡将离开墓地（之后被盖放），以便王家长眠之谷等效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若本卡仍与该效果关联且不受王家长眠之谷影响，则将其在自己场上里侧盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与效果关联且不受王家长眠之谷影响后，将其在自己场上里侧盖放。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end
