--ギャラクシーアイズ・アンチマター・ドラゴン
-- 效果：
-- 9星怪兽×2
-- 「银河眼反物质龙」1回合1次也能在持有超量素材3个以上的自己的超量怪兽上面重叠来超量召唤。
-- ①：持有超量素材的这张卡给与对方的战斗伤害变成一半。
-- ②：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。取除的超量素材是怪兽的场合，可以再把和那只怪兽相同种族的1只怪兽从卡组送去墓地。
local s,id,o=GetID()
-- 注册卡片效果：添加超量召唤手续、设置①效果（持有超量素材时战斗伤害减半）和②效果（去除超量素材获得最多2次向怪兽攻击的能力，并可能从卡组将同种族怪兽送墓）。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,9,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡给与对方的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(s.damcon)
	-- 设置战斗伤害改变效果的值，使给与对方的战斗伤害变成一半。
	e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。取除的超量素材是怪兽的场合，可以再把和那只怪兽相同种族的1只怪兽从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"2次攻击"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	-- 设置发动条件为：当前处于可以进行战斗相关操作的时点或阶段（如主要阶段1或战斗阶段）。
	e2:SetCondition(aux.bpcon)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤重叠超量召唤所需的怪兽：表侧表示且持有3个以上超量素材的自己场上的超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER) and c:GetOverlayCount()>=3
end
-- 重叠超量召唤的操作：检查并注册玩家本回合已使用过该特殊召唤方式的全局标识（限制1回合1次）。
function s.xyzop(e,tp,chk)
	-- 检查本回合是否尚未通过重叠超量怪兽的方式特殊召唤过此卡。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册本回合已通过重叠超量怪兽的方式特殊召唤过此卡的全局标识（誓约效果，回合结束时重置）。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 伤害减半效果的生效条件：这张卡持有超量素材。
function s.damcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- ②效果的发动代价：去除这张卡的1个超量素材。如果去除的是怪兽，则将该怪兽的原本种族记录在效果的Label中，否则记录为0。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 获取刚刚作为代价被去除并送去墓地的超量素材卡片。
	local ct=Duel.GetOperatedGroup():GetFirst()
	if ct:IsType(TYPE_MONSTER) then
		e:SetLabel(ct:GetOriginalRace())
	else
		e:SetLabel(0)
	end
end
-- ②效果的发动准备：检查自身是否尚未获得追加攻击或追加向怪兽攻击的效果，并根据去除的素材是否为怪兽来决定是否将效果分类设为“包含从卡组送去墓地”。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0
		and e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 end
	if e:GetLabel()~=0 then
		e:SetCategory(CATEGORY_DECKDES)
	else
		e:SetCategory(0)
	end
end
-- 过滤卡组中满足条件的卡：与去除的素材怪兽相同种族的怪兽，且可以送去墓地。
function s.tgfilter(c,race)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and c:IsRace(race)
end
-- ②效果的处理：使这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。若去除的素材是怪兽，则可以再从卡组选择1只相同种族的怪兽送去墓地。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain()
		and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
		and c:GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 then
		-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local race=e:GetLabel()
		-- 检查去除的素材是否为怪兽（Label不为0），且卡组中是否存在至少1只相同种族的怪兽。
		if e:GetLabel()~=0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,race)
			-- 询问玩家是否选择发动“从卡组把1只相同种族的怪兽送去墓地”的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽送去墓地？"
			-- 中断当前效果处理，使后续的送墓处理与前面的追加攻击效果不视为同时处理（造成错时点）。
			Duel.BreakEffect()
			-- 在客户端提示玩家选择要送去墓地的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让玩家从卡组选择1只与去除素材相同种族的怪兽。
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,race)
			if g:GetCount()>0 then
				-- 将选择的怪兽因效果送去墓地。
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
