--二量合成
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1张「化合电界」加入手卡。
-- ●从卡组把1张「完全燃烧」和1只「化合兽」怪兽加入手卡。
-- ②：把墓地的这张卡除外，以包含再1次召唤状态的二重怪兽的自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的攻击力变成0，并由另1只怪兽的攻击力上升那个原本攻击力数值。
function c90965652.initial_effect(c)
	-- 在卡片中注册其效果文本中记有「化合电界」和「完全燃烧」的卡片密码
	aux.AddCodeList(c,65959844,25669282)
	-- ①：可以从以下效果选择1个发动。●从卡组把1张「化合电界」加入手卡。●从卡组把1张「完全燃烧」和1只「化合兽」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90965652,0))  --"选择效果发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90965652)
	e1:SetTarget(c90965652.target)
	e1:SetOperation(c90965652.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以包含再1次召唤状态的二重怪兽的自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的攻击力变成0，并由另1只怪兽的攻击力上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90965652,3))  --"改变攻守"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,90965653)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c90965652.atktg)
	e2:SetOperation(c90965652.atkop)
	c:RegisterEffect(e2)
end
c90965652.has_text_type=TYPE_DUAL
-- 过滤卡组中卡名为「化合电界」且能加入手牌的卡
function c90965652.thfilter1(c)
	return c:IsCode(65959844) and c:IsAbleToHand()
end
-- 过滤卡组中卡名为「完全燃烧」且能加入手牌的卡
function c90965652.thfilter2(c)
	return c:IsCode(25669282) and c:IsAbleToHand()
end
-- 过滤卡组中属于「化合兽」系列且是怪兽卡、能加入手牌的卡
function c90965652.thfilter3(c)
	return c:IsSetCard(0xeb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①号效果的发动准备与分支选择处理
function c90965652.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「化合电界」
	local b1=Duel.IsExistingMatchingCard(c90965652.thfilter1,tp,LOCATION_DECK,0,1,nil)
	-- 检查卡组中是否存在可以加入手牌的「完全燃烧」
	local b2=Duel.IsExistingMatchingCard(c90965652.thfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组中是否存在可以加入手牌的「化合兽」怪兽
		and Duel.IsExistingMatchingCard(c90965652.thfilter3,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(90965652,1)  --"「化合电界」加入手卡"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(90965652,2)  --"「完全燃烧」和「化合兽」怪兽加入手卡"
		opval[off-1]=2
		off=off+1
	end
	-- 提示玩家选择要发动的效果分支
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 让玩家选择要发动的分支效果
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local res=opval[op]
	e:SetLabel(res)
	-- 设置连锁信息，将卡组中对应数量的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,res,tp,LOCATION_DECK)
end
-- ①号效果的分支效果处理
function c90965652.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「化合电界」
		local g=Duel.SelectMatchingCard(tp,c90965652.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 检查卡组中是否存在「完全燃烧」
		if Duel.IsExistingMatchingCard(c90965652.thfilter2,tp,LOCATION_DECK,0,1,nil)
			-- 检查卡组中是否存在「化合兽」怪兽
			and Duel.IsExistingMatchingCard(c90965652.thfilter3,tp,LOCATION_DECK,0,1,nil) then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组中选择1张「完全燃烧」
			local g1=Duel.SelectMatchingCard(tp,c90965652.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组中选择1只「化合兽」怪兽
			local g2=Duel.SelectMatchingCard(tp,c90965652.thfilter3,tp,LOCATION_DECK,0,1,1,nil)
			g1:Merge(g2)
			-- 将选中的「完全燃烧」和「化合兽」怪兽加入手牌
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g1)
		end
	end
end
-- 过滤场上表侧表示且可以作为效果对象的怪兽
function c90965652.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 过滤攻击力与原本攻击力均大于0的怪兽
function c90965652.atkfilter(c)
	return c:GetAttack()>0 and c:GetBaseAttack()>0
end
-- 检查选中的怪兽组中是否包含至少1只处于再1次召唤状态的二重怪兽，且包含至少1只攻击力大于0的怪兽
function c90965652.tgcheck(g)
	return g:IsExists(Card.IsDualState,1,nil) and g:IsExists(c90965652.atkfilter,1,nil)
end
-- ②号效果的发动准备与选择对象
function c90965652.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有表侧表示且可以作为效果对象的怪兽
	local g=Duel.GetMatchingGroup(c90965652.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c90965652.tgcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c90965652.tgcheck,false,2,2)
	-- 将选中的2只怪兽注册为效果的对象
	Duel.SetTargetCard(sg)
end
-- ②号效果的处理
function c90965652.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍留在场上且表侧表示的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	if #g<2 then return end
	-- 提示玩家选择要把攻击力变成0的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(90965652,4))  --"请选择要把攻击力变成0的怪兽"
	local g1=g:FilterSelect(tp,c90965652.atkfilter,1,1,nil)
	if #g1<1 then return end
	local tc1=g1:GetFirst()
	local tc2=(g-g1):GetFirst()
	if tc1:IsImmuneToEffect(e) then return end
	-- 直到回合结束时，作为对象的1只怪兽的攻击力变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(0)
	tc1:RegisterEffect(e1)
	-- 并由另1只怪兽的攻击力上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(tc1:GetBaseAttack())
	tc2:RegisterEffect(e2)
end
