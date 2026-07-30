--霊魂プラズマ
-- 效果：
-- 选择1个效果发动。
-- ●自己场上没有怪兽存在的场合：从卡组把1只6星不死族怪兽或者1张「怨念的呼声」加入手卡。
-- ●自己场上的不死族怪兽的攻击力上升400，那之后，可以从卡组抽出自己场上的「活死人的呼声」数量的卡。
-- 「灵魂物质供给」在1回合只能发动1张。
local s,id,o=GetID()
-- 创建此卡的主要效果，设置为发动时可选择一个效果进行处理
function s.initial_effect(c)
	-- 将「怨念的呼声」和「活死人的呼声」加入此卡的代码列表以供识别
	aux.AddCodeList(c,97077563,80749819)
	-- 创建此卡的发动效果，设定其为自由连锁、只能发动一次且具有检索、回手、攻击力变更和抽卡的处理类别
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
-- 定义用于检索的卡片过滤器，筛选出能加入手牌的「怨念的呼声」或6星不死族怪兽
function s.thfilter(c)
	return (c:IsCode(80749819) or (c:IsRace(RACE_ZOMBIE) and c:IsLevel(6))) and c:IsAbleToHand()
end
-- 定义用于判断场上的不死族怪兽是否可以进行攻击力上升效果的过滤器
function s.adfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 设定此卡的发动时点处理函数，检查是否满足两个效果的发动条件并由玩家选择发动哪个效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足检索条件的卡片
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若自己场上没有怪兽存在则满足第一个效果发动条件
		and (not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) or not e:IsCostChecked())
	-- 检查自己场上是否存在不死族怪兽以满足第二个效果发动条件
	local b2=Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从两个效果中选择一个进行发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索"
			{b2,aux.Stringid(id,2),2})  --"攻击力上升"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置操作信息，表示将要从卡组检索一张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
		end
	end
end
-- 定义用于判断场上的「活死人的呼声」的过滤器
function s.drfilter(c)
	return c:IsFaceup() and c:IsCode(97077563)
end
-- 定义用于判断卡片是否未受到倒置增减攻击力效果影响的过滤器
function s.atkupfilter(c)
	return not c:IsHasEffect(EFFECT_REVERSE_UPDATE)
end
-- 执行此卡的效果处理函数，根据玩家选择的效果类型进行不同的处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择一张满足条件的卡加入手牌
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方玩家看到被送入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 获取场上所有符合条件的不死族怪兽
		local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				-- 为选中的不死族怪兽增加400攻击力
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			if g:IsExists(s.atkupfilter,1,nil) then
				-- 计算场上的「活死人的呼声」数量
				local dct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_ONFIELD,0,nil)
				-- 询问玩家是否要抽卡，条件是场上有「活死人的呼声」且玩家可以抽卡
				if dct>0 and Duel.IsPlayerCanDraw(tp,dct) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否抽卡？"
					-- 中断当前效果处理，使后续效果视为错时点处理
					Duel.BreakEffect()
					-- 让玩家从卡组中抽取指定数量的卡
					Duel.Draw(tp,dct,REASON_EFFECT)
				end
			end
		end
	end
end
