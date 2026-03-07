--絢嵐たる海霊ヴァルルーン
-- 效果：
-- 「绚岚」怪兽2只
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1张「旋风」加入手卡。
-- ②：以包含自己场上的「绚岚」怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ③：速攻魔法卡发动的场合才能发动。从自己的卡组·墓地把1张「绚岚」永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化效果函数，注册连接召唤手续并设置复活限制
function s.initial_effect(c)
	-- 记录该卡拥有「旋风」卡名
	aux.AddCodeList(c,5318639)
	-- 设置连接召唤条件为2只「绚岚」怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x1d1),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1张「旋风」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以包含自己场上的「绚岚」怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"当作永续魔法卡放置"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ③：速攻魔法卡发动的场合才能发动。从自己的卡组·墓地把1张「绚岚」永续陷阱卡在自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"放置永续陷阱卡"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2*o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：确认此卡是否为连接召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡牌的过滤函数，筛选「旋风」卡
function s.filter(c)
	return c:IsCode(5318639) and c:IsAbleToHand()
end
-- 效果①的发动时点处理，检查是否有满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果①的处理信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的发动处理，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的过滤函数，筛选可作为对象的怪兽
function s.mvfilter(c)
	return c:IsFaceup() and (c:IsControler(c:GetOwner()) or c:IsAbleToChangeControler())
		and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
end
-- 效果②的过滤函数，筛选可作为对象的怪兽并检查是否受效果影响
function s.mvfilter2(c,e)
	return c:IsType(TYPE_MONSTER) and (c:IsControler(c:GetOwner()) or c:IsAbleToChangeControler())
		and not c:IsImmuneToEffect(e)
		and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
end
-- 判断卡的拥有者是否为指定玩家
function s.isowner(c,tp)
	return c:GetOwner()==tp
end
-- 判断卡是否为「绚岚」卡组且为指定玩家控制
function s.tgfilter(c,tp)
	return c:IsSetCard(0x1d1) and c:IsControler(tp)
end
-- 判断选择的怪兽组是否满足放置条件
function s.gcheck(g,tp)
	-- 判断选择的怪兽组中属于玩家0的怪兽数量是否不超过其魔法区域空位数
	return g:FilterCount(s.isowner,nil,0)<=Duel.GetLocationCount(0,LOCATION_SZONE)
		-- 判断选择的怪兽组中属于玩家1的怪兽数量是否不超过其魔法区域空位数
		and g:FilterCount(s.isowner,nil,1)<=Duel.GetLocationCount(1,LOCATION_SZONE)
		and g:FilterCount(s.tgfilter,nil,tp)>0
end
-- 效果②的发动时点处理，选择并设置目标怪兽
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil):Filter(Card.IsCanBeEffectTarget,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 设置目标卡组
	Duel.SetTargetCard(sg)
end
-- 效果②的发动处理，将目标怪兽放置为永续魔法卡
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e):Filter(s.mvfilter2,nil,e)
	local pg=Group.CreateGroup()
	-- 遍历当前回合玩家和对方玩家
	for p in aux.TurnPlayers() do
		local sg=tg:Filter(s.isowner,nil,p)
		-- 获取指定玩家的魔法区域空位数
		local ct=Duel.GetLocationCount(p,LOCATION_SZONE)
		if sg:GetCount()<=ct then
			pg:Merge(sg)
		elseif ct>0 then
			-- 提示选择要操作的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local tpg=sg:Select(tp,ct,ct,nil)
			pg:Merge(tpg)
		end
	end
	-- 遍历要处理的卡组
	for tc in aux.Next(pg) do
		-- 将卡移动到指定玩家的魔法区域
		Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
		-- 将卡转换为永续魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
	local gg=tg-pg
	if gg:GetCount()>0 then
		-- 将未被处理的卡送入墓地
		Duel.SendtoGrave(gg,REASON_RULE)
	end
end
-- 效果③的发动条件：确认是否为速攻魔法卡发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 筛选「绚岚」永续陷阱卡的过滤函数
function s.pfilter(c,tp)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSetCard(0x1d1)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果③的发动时点处理，检查是否有满足条件的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的魔法区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否有满足条件的卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 效果③的发动处理，选择并放置永续陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的魔法区域空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	-- 将卡移动到指定玩家的魔法区域
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
