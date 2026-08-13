--永の王 オルムガンド
-- 效果：
-- 9星怪兽×2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：「永界王战 欧姆刚德王」在自己场上只能有1只表侧表示存在。
-- ②：这张卡的原本的攻击力·守备力变成这张卡的超量素材数量×1000。
-- ③：把这张卡1个超量素材取除才能发动。双方各自从卡组抽1张。那之后，抽卡的玩家选自身的手卡·场上1张卡在这张卡下面重叠作为超量素材。这个效果在对方回合也能发动。
function c2665273.initial_effect(c)
	c:SetUniqueOnField(1,0,2665273)
	-- 为这张卡添加超量召唤手续：使用任意9星怪兽2只（最多99只）叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ②：这张卡的原本的攻击力·守备力变成这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c2665273.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除才能发动。双方各自从卡组抽1张。那之后，抽卡的玩家选自身的手卡·场上1张卡在这张卡下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2665273,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2665273)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCost(c2665273.drcost)
	e3:SetTarget(c2665273.drtg)
	e3:SetOperation(c2665273.drop)
	c:RegisterEffect(e3)
end
-- 计算这张卡的原本攻击力，数值为超量素材数量×1000，供②效果使用
function c2665273.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 效果③的发动代价：检查并取除这张卡的1个超量素材（取除是发动COST）
function c2665273.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的发动条件：双方玩家都能各抽1张卡时才满足发动条件
function c2665273.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查之一：发动者（tp）可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 发动条件检查之二：对方（1-tp）也能抽1张卡，双方都能抽才可发动
		and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息：预告本效果涉及双方玩家各抽1张卡，供相关卡片的连锁判定使用
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 筛选可叠放为超量素材的卡：可以成为超量素材，且不对此效果免疫（排除本卡自身已在调用处处理）
function c2665273.matfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果③的解决处理：双方各抽1张；抽到的玩家各自从手卡·场上选1张可叠放卡洗牌后选择，叠放到这张卡下；若选中卡自带超量素材则先将那些素材按规则送墓
function c2665273.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发动者（tp）因效果从卡组抽1张，td记录实际抽到的数量
	local td=Duel.Draw(tp,1,REASON_EFFECT)
	-- 对方（1-tp）因效果从卡组抽1张，ed记录实际抽到的数量
	local ed=Duel.Draw(1-tp,1,REASON_EFFECT)
	if td+ed>0 and c:IsRelateToEffect(e) then
		local sg=Group.CreateGroup()
		-- 获取发动者tp的手卡和场上中可作为超量素材的候选卡组，并排除本卡自身
		local tg1=Duel.GetMatchingGroup(c2665273.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),e)
		if td>0 and tg1:GetCount()>0 then
			-- 洗切发动者tp的手卡，避免手卡信息泄露
			Duel.ShuffleHand(tp)
			-- 向tp玩家发送选择提示：请选择要作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local tc1=tg1:Select(tp,1,1,nil):GetFirst()
			if tc1 then
				tc1:CancelToGrave()
				sg:AddCard(tc1)
			end
		end
		-- 获取对方（1-tp）手卡和场上中可作为超量素材的候选卡组，并排除本卡自身
		local tg2=Duel.GetMatchingGroup(c2665273.matfilter,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),e)
		if ed>0 and tg2:GetCount()>0 then
			-- 洗切对方的手卡，避免手卡信息泄露
			Duel.ShuffleHand(1-tp)
			-- 向对方玩家发送选择提示：请选择要作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local tc2=tg2:Select(1-tp,1,1,nil):GetFirst()
			if tc2 then
				tc2:CancelToGrave()
				sg:AddCard(tc2)
			end
		end
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续叠放及相关送墓处理视为不同时进行，避免错过时点
			Duel.BreakEffect()
			-- 遍历本次选出的所有要作为超量素材的卡
			for tc in aux.Next(sg) do
				local og=tc:GetOverlayGroup()
				if og:GetCount()>0 then
					-- 将所选卡上原有超量素材按规则送去墓地（因这些素材无法随卡一起叠放）
					Duel.SendtoGrave(og,REASON_RULE)
				end
			end
			-- 将选出的卡组sg作为超量素材叠放在这张卡（欧姆刚德王）下面
			Duel.Overlay(c,sg)
		end
	end
end
