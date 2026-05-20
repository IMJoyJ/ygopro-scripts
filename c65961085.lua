--魔導獣士 ルード
-- 效果：
-- 这张卡用魔法师族怪兽的效果特殊召唤成功时，选择从游戏中除外的自己的名字带有「魔导书」的魔法卡任意数量才能发动。选择的卡回到卡组，剩下的名字带有「魔导书」的魔法卡回到墓地。「魔导兽士 鲁德」的效果1回合只能使用1次。
function c65961085.initial_effect(c)
	-- 这张卡用魔法师族怪兽的效果特殊召唤成功时，选择从游戏中除外的自己的名字带有「魔导书」的魔法卡任意数量才能发动。选择的卡回到卡组，剩下的名字带有「魔导书」的魔法卡回到墓地。「魔导兽士 鲁德」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65961085,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,65961085)
	e1:SetCondition(c65961085.retcon)
	e1:SetTarget(c65961085.rettg)
	e1:SetOperation(c65961085.retop)
	c:RegisterEffect(e1)
end
-- 检查此卡是否是由魔法师族怪兽的效果特殊召唤成功
function c65961085.retcon(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_SPELLCASTER~=0
end
-- 过滤除外区表侧表示的「魔导书」魔法卡且能回到卡组
function c65961085.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择与操作信息设置
function c65961085.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c65961085.filter(chkc) end
	-- 检查除外区是否存在至少1张符合条件的「魔导书」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c65961085.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外区任意数量符合条件的「魔导书」魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c65961085.filter,tp,LOCATION_REMOVED,0,1,99,nil)
	-- 设置效果处理信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 过滤除外区表侧表示的「魔导书」魔法卡
function c65961085.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 效果处理，将选择的卡送回卡组，剩下的「魔导书」魔法卡送回墓地
function c65961085.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将选择的对象卡片送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	-- 获取除外区剩下的所有表侧表示的「魔导书」魔法卡
	local g2=Duel.GetMatchingGroup(c65961085.filter2,tp,LOCATION_REMOVED,0,nil)
	if g2:GetCount()>0 then
		-- 将剩下的「魔导书」魔法卡送回墓地
		Duel.SendtoGrave(g2,REASON_EFFECT+REASON_RETURN)
	end
end
