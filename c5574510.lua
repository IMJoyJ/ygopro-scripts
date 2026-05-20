--射敵
-- 效果：
-- ①：丢弃1张手卡，以对方场上1只持有等级的怪兽为对象才能发动。掷1次骰子，出现的数目的以下效果适用。
-- ●比作为对象的怪兽的等级大的场合：作为对象的怪兽破坏。那之后，可以把原本等级和那只怪兽相同的1只怪兽从卡组加入手卡。这个回合，自己不能把「射敌」的①的效果发动。
-- ●作为对象的怪兽的等级以下的场合：作为对象的怪兽的等级下降1星。
local s,id,o=GetID()
-- 注册卡片的效果（包括魔法卡的发动效果以及①效果的起动效果）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以对方场上1只持有等级的怪兽为对象才能发动。掷1次骰子，出现的数目的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 检查本回合是否已注册过不能发动「射敌」①效果的玩家标记
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家本回合是否未发动过「射敌」的①效果
	return Duel.GetFlagEffect(tp,id)==0
end
-- 效果发动的代价：丢弃1张手卡
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：表侧表示且等级在1以上的怪兽
function s.desilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 效果发动的目标选择：检查并选择对方场上1只表侧表示且持有等级的怪兽作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.desilter(chkc)
		and chkc~=e:GetHandler() end
	-- 检查对方场上是否存在至少1只满足条件的表侧表示且持有等级的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示且持有等级的怪兽作为效果对象
	Duel.SelectTarget(tp,s.desilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 过滤条件：原本等级与对象怪兽相同且可以加入手卡的怪兽
function s.thfilter(c,lv)
	return c:IsLevel(lv) and c:IsAbleToHand()
end
-- 效果处理：掷1次骰子，根据结果与对象怪兽等级的比较，适用对应的效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		if dc>tc:GetLevel() then
			-- 尝试破坏作为对象的怪兽，并检查是否成功破坏
			if Duel.Destroy(tc,REASON_EFFECT)~=0 then
				local lv=tc:GetOriginalLevel()
				-- 检查卡组中是否存在原本等级与被破坏怪兽相同且可加入手卡的怪兽
				if lv>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lv)
					-- 询问玩家是否选择将原本等级相同的怪兽从卡组加入手卡
					and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽加入手卡？"
					-- 提示玩家选择要加入手牌的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
					-- 从卡组中选择1只原本等级与被破坏怪兽相同的怪兽
					local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
					if g:GetCount()>0 then
						-- 中断当前效果，使后续的检索处理与破坏不视为同时进行
						Duel.BreakEffect()
						-- 将选择的怪兽加入手卡
						Duel.SendtoHand(g,nil,REASON_EFFECT)
						-- 给对方玩家确认加入手卡的卡
						Duel.ConfirmCards(1-tp,g)
					end
				end
			end
			-- 给发动效果的玩家注册本回合已发动过该效果的标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			-- 这个回合，自己不能把「射敌」的①的效果发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))  --"这个回合，自己不能把「射敌」的①的效果发动"
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册限制玩家本回合不能发动「射敌」①效果的全局效果
			Duel.RegisterEffect(e1,tp)
		elseif tc:IsLevelAbove(dc) then
			-- ●作为对象的怪兽的等级以下的场合：作为对象的怪兽的等级下降1星。
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-1)
			tc:RegisterEffect(e1)
		end
	end
end
