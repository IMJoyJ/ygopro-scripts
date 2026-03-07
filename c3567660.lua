--リンク・バック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以额外怪兽区域1只自己的连接怪兽为对象才能发动。那只自己怪兽的位置向作为那所连接区的自己的主要怪兽区域移动。那之后，可以把那只怪兽的连接标记数量的卡从自己卡组上面送去墓地。
function c3567660.initial_effect(c)
	-- 创建效果，设置为发动时点，可以指定对象，限制一回合只能发动一次，设置效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,3567660+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3567660.seqtg)
	e1:SetOperation(c3567660.seqop)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断是否为己方正面表示的连接怪兽且位于额外怪兽区，且其连接区对应的主怪兽区有空位
function c3567660.filter(c,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetSequence()>=5) then return false end
	local zone=bit.band(c:GetLinkedZone(),0x1f)
	-- 判断目标怪兽的连接区所对应的主怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
end
-- 设置效果的目标选择函数，用于选择符合条件的连接怪兽
function c3567660.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3567660.filter(chkc,tp) end
	-- 检查是否满足选择目标的条件，即是否存在符合条件的连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c3567660.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要移动位置的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(3567660,1))  --"请选择要移动位置的卡"
	-- 选择目标怪兽，即选择一只符合条件的连接怪兽
	Duel.SelectTarget(tp,c3567660.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 设置效果的处理函数，用于执行怪兽移动和可能的卡组送墓操作
function c3567660.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(tp)) then return end
	local zone=bit.band(tc:GetLinkedZone(tp),0x1f)
	-- 判断目标怪兽所在区域是否有足够的空位用于移动
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 then
		local flag=bit.bxor(zone,0xff)
		-- 提示玩家选择要移动到的位置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 选择一个可用的主怪兽区位置
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将目标怪兽移动到指定位置
		Duel.MoveSequence(tc,nseq)
		local ct=tc:GetLink()
		-- 判断玩家是否可以将指定数量的卡从卡组送入墓地，并询问是否执行
		if Duel.IsPlayerCanDiscardDeck(tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(3567660,2)) then  --"是否从卡组把卡送去墓地？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将目标怪兽连接标记数量的卡从卡组顶部送入墓地
			Duel.DiscardDeck(tp,ct,REASON_EFFECT)
		end
	end
end
