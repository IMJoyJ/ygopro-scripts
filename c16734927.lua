--霊魂プラズマ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上没有怪兽存在的场合才能发动。从卡组把1只不死族·6星怪兽或1张「来自活死人的呼声」加入手卡。
-- ●自己场上的全部不死族怪兽的攻击力上升400。那之后，自己可以抽出自己场上的「活死人的呼声」的数量。
local s,id,o=GetID()
-- 初始化这张卡：登记相关卡名，创建并注册一个自由时点发动的魔法卡效果，并设置1回合只能发动1次的誓约限制
function s.initial_effect(c)
	-- 登记这张卡上记载着「活死人的呼声」（97077563）和「来自活死人的呼声」（80749819）这两个卡名
	aux.AddCodeList(c,97077563,80749819)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 加入手卡的过滤函数：筛选「来自活死人的呼声」或者不死族·6星且可以加入手卡的卡
function s.thfilter(c)
	return (c:IsCode(80749819) or (c:IsRace(RACE_ZOMBIE) and c:IsLevel(6))) and c:IsAbleToHand()
end
-- 攻击力上升的过滤函数：筛选自己场上表侧表示的不死族怪兽
function s.adfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 发动时的目标处理：判断两个效果选项是否可用，让玩家选择发动其中一个，并根据选择设置效果分类和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「来自活死人的呼声」或不死族·6星怪兽（检索选项的卡片条件）
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且自己场上没有怪兽存在（检索选项的发动条件，发动代价已支付阶段则跳过此检查）
		and (not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) or not e:IsCostChecked())
	-- 检查自己场上是否存在表侧表示的不死族怪兽（攻击力上升选项的发动条件）
	local b2=Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从「检索」和「攻击力上升」两个可用选项中选择1个发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索"
			{b2,aux.Stringid(id,2),2})  --"攻击力上升"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置操作信息：宣告将从卡组把1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
		end
	end
end
-- 抽卡数量的过滤函数：筛选自己场上表侧表示的「活死人的呼声」
function s.drfilter(c)
	return c:IsFaceup() and c:IsCode(97077563)
end
-- 筛选不受攻击力增减倒置效果（天邪鬼类）影响的怪兽，用于判断攻击力是否实际上升
function s.atkupfilter(c)
	return not c:IsHasEffect(EFFECT_REVERSE_UPDATE)
end
-- 效果处理：根据玩家选择的选项，从卡组检索1张卡加入手卡，或让自己场上全部不死族怪兽攻击力上升400，那之后可以按自己场上「活死人的呼声」的数量抽卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 向玩家显示「请选择要加入手牌的卡」的选择提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只不死族·6星怪兽或1张「来自活死人的呼声」
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 把选择的卡以效果原因加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 把加入手卡的卡给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 取得自己场上全部表侧表示的不死族怪兽
		local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				-- ●自己场上的全部不死族怪兽的攻击力上升400。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			if g:IsExists(s.atkupfilter,1,nil) then
				-- 统计自己场上表侧表示的「活死人的呼声」的数量作为可抽卡数量
				local dct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_ONFIELD,0,nil)
				-- 若存在「活死人的呼声」、自己可以抽对应数量的卡且玩家选择「是」，则进入抽卡处理
				if dct>0 and Duel.IsPlayerCanDraw(tp,dct) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否抽卡？"
					-- 中断当前效果处理，使抽卡与攻击力上升视为不同时处理
					Duel.BreakEffect()
					-- 让玩家抽出自己场上「活死人的呼声」的数量的卡
					Duel.Draw(tp,dct,REASON_EFFECT)
				end
			end
		end
	end
end
