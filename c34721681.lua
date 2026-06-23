--超重機回送
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「无限起动」怪兽加入手卡。
-- ②：1回合1次，可以以自己场上1只机械族超量怪兽为对象，从以下效果选择1个发动。
-- ●那只怪兽的表示形式变更。
-- ●把这张卡在那只怪兽下面重叠作为超量素材。
function c34721681.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「无限起动」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34721681+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c34721681.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，可以以自己场上1只机械族超量怪兽为对象，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c34721681.postg)
	e2:SetOperation(c34721681.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的「无限起动」怪兽（类型为怪兽、种族为无限起动、可以加入手牌）
function c34721681.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x127) and c:IsAbleToHand()
end
-- 发动时处理效果：检索满足条件的怪兽并选择是否加入手牌
function c34721681.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「无限起动」怪兽组
	local g=Duel.GetMatchingGroup(c34721681.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的怪兽且玩家选择加入手牌
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(34721681,0)) then  --"是否把1只「无限起动」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤函数，用于检索满足条件的机械族超量怪兽（表侧表示、种族为机械、类型为超量、可以变更表示形式）
function c34721681.pfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ) and c:IsCanChangePosition()
end
-- 过滤函数，用于检索满足条件的机械族超量怪兽（表侧表示、种族为机械、类型为超量）
function c34721681.pfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
-- 处理效果选择：判断是否可以发动效果并设置目标
function c34721681.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否存在满足条件1的机械族超量怪兽
	local b1=Duel.IsExistingTarget(c34721681.pfilter1,tp,LOCATION_MZONE,0,1,nil)
	-- 判断是否存在满足条件2的机械族超量怪兽且此卡可以作为超量素材
	local b2=Duel.IsExistingTarget(c34721681.pfilter2,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and (c34721681.pfilter1(chkc) or c34721681.pfilter2(chkc) and e:GetHandler():IsCanOverlay()) end
	if chk==0 then return b1 or b2 end
	local opt=0
	local g=nil
	if b1 and not b2 then
		-- 选择效果1：表示形式变更
		opt=Duel.SelectOption(tp,aux.Stringid(34721681,1))  --"表示形式变更"
	end
	if not b1 and b2 then
		-- 选择效果2：补充超量素材
		opt=Duel.SelectOption(tp,aux.Stringid(34721681,2))+1  --"补充超量素材"
	end
	if b1 and b2 then
		-- 选择效果1或效果2：表示形式变更/补充超量素材
		opt=Duel.SelectOption(tp,aux.Stringid(34721681,1),aux.Stringid(34721681,2))  --"表示形式变更/补充超量素材"
	end
	e:SetLabel(opt)
	if opt==0 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择满足条件1的机械族超量怪兽作为对象
		g=Duel.SelectTarget(tp,c34721681.pfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	else
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择满足条件2的机械族超量怪兽作为对象
		g=Duel.SelectTarget(tp,c34721681.pfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
-- 处理效果选择后的操作：根据选择的效果变更表示形式或叠放此卡作为超量素材
function c34721681.posop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if opt==0 then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	else
		if c:IsRelateToEffect(e) and c:IsCanOverlay() and not tc:IsImmuneToEffect(e) then
			-- 将此卡叠放于目标怪兽下方作为超量素材
			Duel.Overlay(tc,c)
		end
	end
end
