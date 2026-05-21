--聖蛇の息吹
-- 效果：
-- 自己场上有仪式·融合·同调·超量怪兽之内2种类以上存在的场合，可以从那些怪兽种类的以下效果选1个以上发动。「圣蛇的息吹」在1回合只能发动1张。
-- ●2种类以上：选择自己墓地1只怪兽或者从游戏中除外的1只自己怪兽加入手卡。
-- ●3种类以上：选择自己墓地1张陷阱卡加入手卡。
-- ●4种类：选择「圣蛇的息吹」以外的自己墓地1张魔法卡加入手卡。
function c98850929.initial_effect(c)
	-- 自己场上有仪式·融合·同调·超量怪兽之内2种类以上存在的场合，可以从那些怪兽种类的以下效果选1个以上发动。●2种类以上：选择自己墓地1只怪兽或者从游戏中除外的1只自己怪兽加入手卡。●3种类以上：选择自己墓地1张陷阱卡加入手卡。●4种类：选择「圣蛇的息吹」以外的自己墓地1张魔法卡加入手卡。「圣蛇的息吹」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98850929,4))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,98850929+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c98850929.target)
	e1:SetOperation(c98850929.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的仪式、融合、同调、超量怪兽
function c98850929.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 获取卡片的类型，并过滤出仪式、融合、同调、超量这四种类型，用于计算种类数量
function c98850929.typecast(c)
	return bit.band(c:GetType(),TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤自己墓地或除外状态的、可以加入手牌且可以作为效果对象的怪兽
function c98850929.filter1(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 过滤自己墓地的、可以加入手牌且可以作为效果对象的陷阱卡
function c98850929.filter2(c,e)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 过滤自己墓地的、除「圣蛇的息吹」以外、可以加入手牌且可以作为效果对象的魔法卡
function c98850929.filter3(c,e)
	return c:IsType(TYPE_SPELL) and not c:IsCode(98850929) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 效果发动时的目标选择与处理，检测场上怪兽种类数量并让玩家选择并决定要加入手牌的对象卡片
function c98850929.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有的表侧表示仪式、融合、同调、超量怪兽
	local g=Duel.GetMatchingGroup(c98850929.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(c98850929.typecast)
	-- 获取自己墓地及除外区中满足回收条件的怪兽卡组
	local g1=Duel.GetMatchingGroup(c98850929.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取自己墓地中满足回收条件的陷阱卡组
	local g2=Duel.GetMatchingGroup(c98850929.filter2,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取自己墓地中满足回收条件的魔法卡组
	local g3=Duel.GetMatchingGroup(c98850929.filter3,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return (ct>1 and g1:GetCount()>0) or (ct>2 and g2:GetCount()>0) or (ct>3 and g3:GetCount()>0) end
	local tg=Group.CreateGroup()
	local off=0
	repeat
		local ops={}
		local opval={}
		off=1
		if ct>1 and g1:GetCount()>0 then
			ops[off]=aux.Stringid(98850929,0)  --"2种类以上：回收怪兽"
			opval[off-1]=1
			off=off+1
		end
		if ct>2 and g2:GetCount()>0 then
			ops[off]=aux.Stringid(98850929,1)  --"3种类以上：回收陷阱"
			opval[off-1]=2
			off=off+1
		end
		if ct>3 and g3:GetCount()>0 then
			ops[off]=aux.Stringid(98850929,2)  --"4种类：回收魔法"
			opval[off-1]=3
			off=off+1
		end
		-- 提示玩家从当前可发动的效果选项中选择一个
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			-- 提示玩家选择要加入手牌的怪兽卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g1:Select(tp,1,1,nil)
			tg:Merge(sg)
			g1:Clear()
		elseif opval[op]==2 then
			-- 提示玩家选择要加入手牌的陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g2:Select(tp,1,1,nil)
			tg:Merge(sg)
			g2:Clear()
		else
			-- 提示玩家选择要加入手牌的魔法卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g3:Select(tp,1,1,nil)
			tg:Merge(sg)
			g3:Clear()
		end
	-- 循环选择效果，直到没有可选效果或玩家选择不再继续
	until off<3 or not Duel.SelectYesNo(tp,aux.Stringid(98850929,3))  --"是否要继续选择「圣蛇的息吹」的效果发动？"
	-- 将所有选中的卡片设为该效果的对象
	Duel.SetTargetCard(tg)
	-- 设置当前连锁的操作信息，表明此效果的处理包含将选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,tg:GetCount(),0,0)
end
-- 效果处理函数，将成为对象且仍合法的卡片加入手牌并给对方确认
function c98850929.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被设为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍合法的对象卡片加入持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
