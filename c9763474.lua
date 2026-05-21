--盛悴のリザルドーズ
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：从自己的场上（表侧表示）·墓地把1只攻击力2000以下的怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成和为这个效果发动而除外的怪兽的原本攻击力相同。把原本种族是爬虫类族的怪兽除外发动的场合，再让自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续和①效果的注册
function s.initial_effect(c)
	-- 设定连接召唤手续：需要2只怪兽，且满足s.lcheck过滤条件（卡名不同）
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：从自己的场上（表侧表示）·墓地把1只攻击力2000以下的怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成和为这个效果发动而除外的怪兽的原本攻击力相同。把原本种族是爬虫类族的怪兽除外发动的场合，再让自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.accost)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
end
-- 连接素材的过滤条件：用于检查作为连接素材的怪兽卡名是否各不相同
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 过滤条件：检查怪兽是否表侧表示存在，且当前攻击力不等于目标攻击力
function s.atkcheck(c,atk)
	return c:IsFaceup() and c:GetAttack()~=atk
end
-- 过滤条件：检查自己场上表侧表示或墓地中，是否存在可作为发动代价除外的、攻击力2000以下的怪兽，且该怪兽除外后有合法的攻击力变更对象（若为爬虫类族还需满足玩家可抽卡）
function s.cfilter(c)
	return c:IsAttackBelow(2000) and c:GetTextAttack()>=0 and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		-- 检查如果除外的怪兽原本种族是爬虫类族，则必须满足玩家当前可以抽卡的条件
		and (Duel.IsPlayerCanDraw(c:GetControler(),1) or c:GetOriginalRace()~=RACE_REPTILE)
		-- 检查场上是否存在除自身外、攻击力不等于该卡原本攻击力的表侧表示怪兽作为对象
		and Duel.IsExistingTarget(s.atkcheck,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetBaseAttack())
end
-- ①效果的发动代价处理函数，选择并除外1只怪兽，并记录其原本攻击力和原本种族
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：检查自己场上或墓地是否存在满足除外条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 过滤并选择1张自己场上或墓地满足条件的怪兽作为发动代价
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetLabel(tc:GetBaseAttack(),tc:GetOriginalRace())
end
-- ①效果的对象选择与效果分类判定函数
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk,race=e:GetLabel()
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and chkc:GetAttack()~=atk end
	-- 发动条件检查：检查场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示且攻击力不等于除外怪兽原本攻击力的怪兽作为效果对象
	Duel.SelectTarget(tp,s.atkcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	if race==RACE_REPTILE then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
-- ①效果的效果处理函数，变更对象怪兽的攻击力，若除外的是爬虫类族怪兽则再抽1张卡
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时已选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local atk,race=e:GetLabel()
	if tc:IsType(TYPE_MONSTER) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()~=atk then
		-- 那只怪兽的攻击力直到回合结束时变成和为这个效果发动而除外的怪兽的原本攻击力相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		if race==RACE_REPTILE then
			-- 中断当前效果处理，使后续的抽卡处理不与攻击力变更同时进行
			Duel.BreakEffect()
			-- 让发动效果的玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
