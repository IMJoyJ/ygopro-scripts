--超重機回送
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「无限起动」怪兽加入手卡。
-- ②：1回合1次，可以以自己场上1只机械族超量怪兽为对象，从以下效果选择1个发动。
-- ●那只怪兽的表示形式变更。
-- ●把这张卡在那只怪兽下面重叠作为超量素材。
function c34721681.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「无限起动」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34721681+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c34721681.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，可以以自己场上1只机械族超量怪兽为对象，从以下效果选择1个发动。●那只怪兽的表示形式变更。●把这张卡在那只怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c34721681.postg)
	e2:SetOperation(c34721681.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：从卡组中筛选满足“怪兽卡、属于「无限起动」系列、且可以加入手卡”的卡，作为①检索的对象候选。
function c34721681.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x127) and c:IsAbleToHand()
end
-- ①效果的发动时操作：在卡组中寻找符合条件的「无限起动」怪兽；若存在且玩家选择“是”，则进行检索、加入手卡并向对方展示。
function c34721681.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家卡组中所有满足thfilter条件的卡（即「无限起动」怪兽且能加入手卡）的集合。
	local g=Duel.GetMatchingGroup(c34721681.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否存在可检索的卡，并由玩家决定是否发动检索；只有在集合非空且玩家选择“是”时才继续处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(34721681,0)) then  --"是否把1只「无限起动」怪兽加入手卡？"
		-- 给玩家发送“请选择要加入手牌的卡”的提示，用于进入选择卡片的选卡界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的那张「无限起动」怪兽加入其持有者的手卡，检索处理原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认（公开检索到的卡）。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤函数：用于“表示形式变更”选项，判断怪兽是否为表侧表示、机械族、超量怪兽，且能够被效果变更表示形式。
function c34721681.pfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ) and c:IsCanChangePosition()
end
-- 过滤函数：用于“补充超量素材”选项，判断怪兽是否为表侧表示、机械族、超量怪兽（是否可变更表示形式无关）。
function c34721681.pfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
-- ②效果的目标选择函数前半部分：分别计算两种选项是否存在可用对象；在连锁处理时确认对象是否合法（必须是己方场上表侧机械族超量怪兽，且若是补充素材选项还要本卡可作为超量素材）。
function c34721681.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在至少1只满足pfilter1的怪兽（表侧机械族超量且可变更表示形式），从而决定“表示形式变更”选项是否可选。
	local b1=Duel.IsExistingTarget(c34721681.pfilter1,tp,LOCATION_MZONE,0,1,nil)
	-- 检查自己场上是否存在至少1只满足pfilter2的怪兽（表侧机械族超量），并且这张卡自身可以作为超量素材，从而决定“补充超量素材”选项是否可选。
	local b2=Duel.IsExistingTarget(c34721681.pfilter2,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and (c34721681.pfilter1(chkc) or c34721681.pfilter2(chkc) and e:GetHandler():IsCanOverlay()) end
	if chk==0 then return b1 or b2 end
	local opt=0
	local g=nil
	if b1 and not b2 then
		-- 当只有“表示形式变更”可选时，让玩家选择该选项，选择结果(0)存入效果的Label，表示后续执行变更表示形式。
		opt=Duel.SelectOption(tp,aux.Stringid(34721681,1))  --"表示形式变更"
	end
	if not b1 and b2 then
		-- 当只有“补充超量素材”可选时，让玩家选择该选项，Duel.SelectOption返回0后加1得到1，存入效果的Label，表示后续执行叠放素材。
		opt=Duel.SelectOption(tp,aux.Stringid(34721681,2))+1  --"补充超量素材"
	end
	if b1 and b2 then
		-- 当两个选项都可用时，让玩家选择其中一个；选择0表示“表示形式变更”，选择1表示“补充超量素材”，并将选择结果存入效果的Label。
		opt=Duel.SelectOption(tp,aux.Stringid(34721681,1),aux.Stringid(34721681,2))  --"表示形式变更/补充超量素材"
	end
	e:SetLabel(opt)
	if opt==0 then
		-- 发送“请选择效果的对象”的提示，让玩家开始选择要处理的机械族超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 在选择了“表示形式变更”的情况下，从满足pfilter1的怪兽中选取1只作为效果对象。
		g=Duel.SelectTarget(tp,c34721681.pfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	else
		-- 发送“请选择效果的对象”的提示，让玩家开始选择要处理的机械族超量怪兽（补充超量素材选项的分支同样需要此提示）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 在选择了“补充超量素材”的情况下，从满足pfilter2的怪兽中选取1只作为效果对象。
		g=Duel.SelectTarget(tp,c34721681.pfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
-- ②效果的实际处理：取出记录的选择选项和对象怪兽；先确认对象仍与该效果关联；若选择的是变更表示形式则反转其表示形式；若选择的是补充超量素材，则在这张卡仍在场上且可作为超量素材、对象不免疫此效果时，将这张卡叠放到对象下方成为超量素材。
function c34721681.posop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local c=e:GetHandler()
	-- 获取②效果发动时选择的目标怪兽（当前连锁的第一个对象）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if opt==0 then
		-- 变更对象怪兽的表示形式：将表侧攻击表示变成表侧守备表示，将表侧守备表示变成表侧攻击表示，即反转其攻守表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	else
		if c:IsRelateToEffect(e) and c:IsCanOverlay() and not tc:IsImmuneToEffect(e) then
			-- 将这张「超重机回送」卡片叠放到目标超量怪兽下方，作为它的超量素材。
			Duel.Overlay(tc,c)
		end
	end
end
