--ファニー・ダーク・ラビット
local s,id,o=GetID()
-- 初始化效果函数，注册召唤成功和特殊召唤成功时的处理效果，并添加类型为卡通的效果以及检索手牌的效果
function s.initial_effect(c)
	-- 将卡号15259703加入该卡的效果文本记录中
	aux.AddCodeList(c,15259703)
	-- 当此卡通常召唤成功时触发的效果，用于增加额外召唤次数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 当此卡在场上时，若存在15259703的表侧表示怪兽，则变为卡通怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_TYPE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.addcon)
	e3:SetValue(TYPE_TOON)
	c:RegisterEffect(e3)
	-- 此卡在场上时可发动的起动效果，可以从牌组检索并特殊召唤或送入手牌
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 用于判断是否满足额外召唤条件的过滤函数
function s.sumfilter(e,c)
	-- 检测目标卡片是否记载着15259703这张卡
	return aux.IsCodeListed(c,15259703)
end
-- 当此卡召唤成功时触发的操作函数，用于注册额外召唤次数效果和标识效果
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否已经使用过该效果（防止重复使用）
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	-- 向所有玩家显示此卡的发动动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 注册一个影响全场的额外召唤次数效果，并设置标识效果防止重复使用
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.sumfilter)
	-- 将额外召唤次数效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，用于记录该效果已使用过
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 用于判断场上是否存在15259703的表侧表示怪兽的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 判断此卡是否满足添加卡通类型的条件
function s.addcon(e)
	-- 检测场上是否存在15259703的表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 用于筛选可检索的魔法卡的过滤函数
function s.thfilter(c,tp)
	if not (c:IsSetCard(0x62) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS)) then return false end
	return c:IsAbleToHand() or not c:IsForbidden() and c:CheckUniqueOnField(tp)
		-- 判断目标魔法卡是否可以特殊召唤到场上的条件之一
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- 设置检索效果的目标函数，检查是否有满足条件的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家牌组中是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 检索效果的处理函数，选择并处理检索到的卡片
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从玩家牌组中选择一张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 判断目标魔法卡是否可以特殊召唤到场上的条件
		local pchk=not tc:IsForbidden() and tc:CheckUniqueOnField(tp) and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		-- 如果目标魔法卡可以送入手牌且满足特殊召唤条件则选择送入手牌
		if tc:IsAbleToHand() and (not pchk or Duel.SelectOption(tp,1190,aux.Stringid(id,3))==0) then
			-- 将目标魔法卡送入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方玩家看到该魔法卡
			Duel.ConfirmCards(1-tp,tc)
		elseif pchk then
			if tc then
				if tc:IsType(TYPE_CONTINUOUS) then
					-- 将目标魔法卡移动到玩家场上（通常魔法区域）
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				else
					-- 将目标魔法卡移动到玩家场上（场地魔法区域）
					Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end
