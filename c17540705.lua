--EMダグ・ダガーマン
-- 效果：
-- ←2 【灵摆】 2→
-- 「娱乐伙伴 奇人飞剑手」的灵摆效果1回合只能使用1次。
-- ①：这张卡发动的回合的自己主要阶段以自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- 「娱乐伙伴 奇人飞剑手」的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤成功的回合的自己主要阶段从手卡把1只「娱乐伙伴」怪兽送去墓地才能发动。自己从卡组抽1张。
function c17540705.initial_effect(c)
	-- 为灵摆怪兽添加灵摆召唤与灵摆区域相关固有属性；false表示不自动注册灵摆卡自身的发动效果，此处发动效果由后续的e1手动实现。
	aux.EnablePendulumAttribute(c,false)
	-- ←2 【灵摆】 2→；这张卡发动的回合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c17540705.threg)
	c:RegisterEffect(e1)
	-- 「娱乐伙伴 奇人飞剑手」的灵摆效果1回合只能使用1次。①：这张卡发动的回合的自己主要阶段以自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17540705,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,17540705)
	e2:SetCondition(c17540705.thcon)
	e2:SetTarget(c17540705.thtg)
	e2:SetOperation(c17540705.thop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】这张卡灵摆召唤成功的回合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c17540705.regcon)
	e3:SetOperation(c17540705.drreg)
	c:RegisterEffect(e3)
	-- 「娱乐伙伴 奇人飞剑手」的怪兽效果1回合只能使用1次。①：这张卡灵摆召唤成功的回合的自己主要阶段从手卡把1只「娱乐伙伴」怪兽送去墓地才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17540705,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,17540706)
	e4:SetCondition(c17540705.drcon)
	e4:SetCost(c17540705.drcost)
	e4:SetTarget(c17540705.drtg)
	e4:SetOperation(c17540705.drop)
	c:RegisterEffect(e4)
end
-- e1的Cost：这张卡发动时给自己打上17540705誓约标记，用于记录本回合已发动过，标记在回合结束或离场等标准时机重置。
function c17540705.threg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(17540705,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- e2的发动条件：判断这张卡是否带有17540705标记，即本回合是否发动过灵摆卡；若已发动，才能在主要阶段发动回收效果。
function c17540705.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17540705)~=0
end
-- 墓地回收对象的过滤器：筛选“娱乐伙伴”字段、怪兽类型且能加入手卡的卡。
function c17540705.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- e2的取对象发动处理：确认对象合法后，选择自己墓地1只符合条件的“娱乐伙伴”怪兽作为对象，并设置将1张卡加入手卡的操作信息。
function c17540705.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c17540705.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只满足thfilter条件的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17540705.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，提示玩家选择要加入手卡的卡（对应“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足thfilter条件的“娱乐伙伴”怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c17540705.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：处理分类为CATEGORY_TOHAND，对象为选择的1张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- e2的效果处理：取得对象卡，若对象仍与该效果关联，则将其加入手卡。
function c17540705.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡，即之前选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送回持有者手卡，实现“那只怪兽加入手卡”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- e3的触发条件：这张卡成功灵摆召唤时触发（以召唤类型SUMMON_TYPE_PENDULUM判定）。
function c17540705.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- e3的效果处理：在灵摆召唤成功时给这张卡设置17540706标记，记录本回合灵摆召唤成功过，该标记在回合结束/离场等时机重置。
function c17540705.drreg(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17540706,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- e4的发动条件：检查这张卡带有17540706标记，即本回合灵摆召唤成功过才能发动抽卡效果。
function c17540705.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17540706)~=0
end
-- Cost用的手卡筛选：选择满足“娱乐伙伴”字段、怪兽类型且能作为Cost送去墓地的卡。
function c17540705.cfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- e4的Cost处理：确认手卡存在可丢弃的“娱乐伙伴”怪兽后，从手卡丢弃1张符合条件的怪兽作为发动代价。
function c17540705.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost合法性检查：确认手卡中存在至少1张满足cfilter条件的“娱乐伙伴”怪兽可以作为Cost丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c17540705.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选择并丢弃1张符合条件的“娱乐伙伴”怪兽到墓地，作为效果的发动Cost。
	Duel.DiscardHand(tp,c17540705.cfilter,1,1,REASON_COST)
end
-- e4的发动目标处理：确认玩家可以抽1张卡，设定抽卡玩家为自身、抽卡数量为1，并设置抽卡操作信息。
function c17540705.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认当前玩家tp可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为tp，表示抽卡玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示要抽的卡数为1张。
	Duel.SetTargetParam(1)
	-- 设置连锁处理信息：处理分类为CATEGORY_DRAW，预计抽牌玩家为tp、抽1张；不取对象所以targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- e4的效果处理：从连锁信息中取出对象玩家和抽卡数量，并让该玩家抽相应数量的卡。
function c17540705.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出抽卡玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，实现“自己从卡组抽1张”。
	Duel.Draw(p,d,REASON_EFFECT)
end
