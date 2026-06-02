--Ectoplasmic Fortification
-- 效果：
-- 选择1个效果发动。
-- ●自己场上没有怪兽存在的场合：从卡组把1只6星不死族怪兽或者1张「怨念的呼声」加入手卡。
-- ●自己场上的不死族怪兽的攻击力上升400，那之后，可以从卡组抽出自己场上的「活死人的呼声」数量的卡。
-- 「灵魂物质供给」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化卡片效果，记录关联卡片，并注册此卡的发动效果
function s.initial_effect(c)
	-- 注册该卡记录了「活死人的呼声」与「怨念的呼声」这两张卡名
	aux.AddCodeList(c,97077563,80749819)
	-- 选择1个效果发动。
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
-- 过滤条件：卡组的「怨念的呼声」或者6星的不死族怪兽
function s.thfilter(c)
	return (c:IsCode(80749819) or (c:IsRace(RACE_ZOMBIE) and c:IsLevel(6))) and c:IsAbleToHand()
end
-- 过滤条件：自己场上表侧表示的不死族怪兽
function s.adfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 效果发动的判定与目标选择：检查可发动效果的分支条件并让玩家选择其一，同时设定对应的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判定自己场上没有怪兽存在的场合
		and (not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) or not e:IsCostChecked())
	-- 检查自己场上是否存在表侧表示的不死族怪兽
	local b2=Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择其中一个效果发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索"
			{b2,aux.Stringid(id,2),2})  --"攻击力上升"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置连锁的操作信息：预计将卡组的1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
		end
	end
end
-- 过滤条件：自己场上表侧表示的「活死人的呼声」
function s.drfilter(c)
	return c:IsFaceup() and c:IsCode(97077563)
end
-- 过滤条件：不受反转攻击力增减效果影响的怪兽
function s.atkupfilter(c)
	return not c:IsHasEffect(EFFECT_REVERSE_UPDATE)
end
-- 效果处理：根据发动的分支执行检索并加入手卡，或者提升不死族攻击力并根据情况抽卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 向玩家显示选择加入手卡卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡片加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 获取自己场上所有表侧表示的不死族怪兽
		local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				-- 自己场上的不死族怪兽的攻击力上升400
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			if g:IsExists(s.atkupfilter,1,nil) then
				-- 统计自己场上表侧表示的「活死人的呼声」的数量
				local dct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_ONFIELD,0,nil)
				-- 若满足抽卡条件，则询问玩家是否选择抽卡
				if dct>0 and Duel.IsPlayerCanDraw(tp,dct) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否抽卡？"
					-- 中断当前效果，使前后的处理不视为同时进行
					Duel.BreakEffect()
					-- 从卡组抽出自己场上的「活死人的呼声」数量的卡
					Duel.Draw(tp,dct,REASON_EFFECT)
				end
			end
		end
	end
end
