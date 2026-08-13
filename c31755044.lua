--十二獣ヴァイパー
-- 效果：
-- ①：以自己场上1只兽战士族超量怪兽为对象才能发动。把自己的手卡·场上的这张卡在那只怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽除外。
function c31755044.initial_effect(c)
	-- ①：以自己场上1只兽战士族超量怪兽为对象才能发动。把自己的手卡·场上的这张卡在那只怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31755044,0))  --"这张卡重叠作为超量素材"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c31755044.mattg)
	e1:SetOperation(c31755044.matop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31755044,1))  --"进行战斗的对方怪兽除外（十二兽 蛇笞）"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c31755044.rmcon)
	e2:SetTarget(c31755044.rmtg)
	e2:SetOperation(c31755044.rmop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：检查卡片是否为表侧表示、兽战士族、超量怪兽，用于选择自己场上符合条件的超量怪兽作为对象。
function c31755044.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_XYZ)
end
-- 效果发动时的目标判定：检查此卡不在连锁串中、自己场上有符合条件的兽战士族超量怪兽、且此卡可作为超量素材；若有指定对象则校验对象是否满足条件。
function c31755044.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31755044.matfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否存在至少1只满足条件的兽战士族超量怪兽，确保有合法对象可选取。
		and Duel.IsExistingTarget(c31755044.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向操作玩家发送选择对象的提示消息，显示“请选择效果的对象”的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的兽战士族超量怪兽，并将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,c31755044.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取此卡与对象卡，若两者仍与效果关联、对象不免疫此效果、且此卡可作为超量素材，则将此卡重叠到对象下方作为超量素材。
function c31755044.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象卡（即那只兽战士族超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
		-- 将这张卡（蛇笞）作为超量素材，叠放到目标超量怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 除外的发动条件判定：作为素材的超量怪兽原本种族为兽战士族，且与对方怪兽进行了战斗，战斗对象仍与战斗关联；同时把战斗对象记录到LabelObject中。
function c31755044.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and bc and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle()
end
-- 发动时的目标/效果登记：必发效果满足条件即可发动，向对方提示效果，并把战斗对象设置为将除外的卡片。
function c31755044.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示我方发动了该效果（显示效果描述文本），作为操作提示。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：指定除外类别，对象为记录的战斗对象，数量为1，供系统进行效果发动检测和连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 效果处理：若记录的战斗对象仍与战斗关联且由对方控制，则将其除外。
function c31755044.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将战斗对象以表侧表示形式除外，理由为效果。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
