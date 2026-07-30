--機叡のメカチューナー
-- 效果：
-- 其他的自己的机械族怪兽进行战斗的攻击宣言时：可以让那只自己怪兽的等级上升或者下降1。
-- 「机械型机械师」的以下效果1回合各能使用1次。
-- 场地区域有卡存在的场合：可以把这张卡从手卡特殊召唤。
-- 可以以自己场上1张表侧表示的魔法·陷阱卡为对象；那张卡破坏，从卡组把1只攻击力0的机械族·风属性怪兽加入手卡。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 创建三个效果，分别对应等级改变、特殊召唤和破坏并检索的效果。
function s.initial_effect(c)
	-- 其他的自己的机械族怪兽进行战斗的攻击宣言时：可以让那只自己怪兽的等级上升或者下降1。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级改变"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.lvcon)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- 场地区域有卡存在的场合：可以把这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 可以以自己场上1张表侧表示的魔法·陷阱卡为对象；那张卡破坏，从卡组把1只攻击力0的机械族·风属性怪兽加入手卡。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏并检索"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 判断攻击怪兽是否为己方机械族怪兽且未被本卡自身影响。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 获取当前攻击目标怪兽。
	local bc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	e:SetLabelObject(ac)
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsRace(RACE_MACHINE) and ac~=c
end
-- 设置等级改变效果的处理目标，确保攻击怪兽等级大于等于1。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 获取当前攻击目标怪兽。
	local bc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	if chk==0 then return ac:IsLevelAbove(1) end
end
-- 执行等级改变操作，根据选择决定提升或降低等级。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsType(TYPE_MONSTER) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 创建一个用于修改等级的效果，并设置其值为+1或-1。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		-- 当攻击怪兽等级大于等于2时，询问玩家选择提升还是降低等级。
		if tc:IsLevelAbove(2) and Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==1 then  --"上升等级/下降等级"
			e1:SetValue(-1)
		else
			e1:SetValue(1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断场地区域是否存在卡（即F-zone是否被占用）。
function s.spcon(e)
	-- 检查场地区域是否有至少一张卡存在。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置特殊召唤效果的处理条件，确保有空位且本卡可被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场上空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤本卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将本卡从手牌特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 使用Duel.SpecialSummon函数将卡特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义用于筛选魔法·陷阱卡的过滤器函数。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义用于检索攻击力为0、种族为机械族、属性为风的怪兽的过滤器函数。
function s.thfilter(c)
	return c:IsAttack(0) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- 设置破坏并检索效果的目标选择条件，确保目标为己方场上表侧表示的魔法或陷阱卡，并且卡组中存在符合条件的怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否至少有一张己方场上的魔法或陷阱卡满足条件。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查卡组中是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一张己方场上表侧表示的魔法或陷阱卡作为目标。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置操作信息，表示将要破坏目标卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要从卡组检索一张怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行破坏并检索效果的操作，包括破坏目标卡、从卡组检索符合条件的怪兽并加入手牌，并注册限制非机械族怪兽从额外卡组特殊召唤的效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于连锁中且成功被破坏。
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择一张符合条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽送入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认所选怪兽。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 创建一个限制非机械族怪兽从额外卡组特殊召唤的效果，并注册到场上。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到指定玩家的场上。
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制非机械族怪兽从额外卡组特殊召唤的效果函数。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
