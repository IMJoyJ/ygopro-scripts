--機叡のメカチューナー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场地区域有卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组把1只攻击力0的机械族·风属性怪兽加入手卡。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
-- ③：其他的自己的机械族怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的等级上升或下降1星。
local s,id,o=GetID()
-- 注册这张卡的三个效果：攻击宣言时触发的等级变更诱发效果、从手卡特殊召唤的起动效果（1回合1次）、破坏场上魔法陷阱并检索卡组怪兽的起动效果（1回合1次）。
function s.initial_effect(c)
	-- ③：其他的自己的机械族怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的等级上升或下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级改变"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.lvcon)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ①：场地区域有卡存在的场合才能发动。这张卡从手卡特殊召唤。这个卡名的①的效果1回合只能使用1次。
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
	-- ②：以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组把1只攻击力0的机械族·风属性怪兽加入手卡。这个卡名的②的效果1回合只能使用1次。
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
-- 发动条件判定：取得攻击怪兽与攻击对象，若攻击方不是自己则交换，将攻击怪兽存入标签对象，确认进行战斗攻击宣言的是这张卡以外自己场上表侧表示的机械族怪兽。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得此次攻击宣言的攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 取得此次攻击宣言的攻击对象怪兽。
	local bc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	e:SetLabelObject(ac)
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsRace(RACE_MACHINE) and ac~=c
end
-- 目标阶段判定：取得攻击怪兽与攻击对象并调整为攻击方是自己的视角，发动时确认攻击怪兽等级在1以上（可以改变等级）。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得此次攻击宣言的攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 取得此次攻击宣言的攻击对象怪兽。
	local bc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	if chk==0 then return ac:IsLevelAbove(1) end
end
-- 效果处理：取得之前存入的攻击怪兽，若它仍在战斗中且为自己场上表侧表示的怪兽，则注册一个改变等级的永续效果——等级2以上时让玩家选择上升或下降1星，否则固定上升1星，直到该怪兽离开场上或效果被重置为止。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsType(TYPE_MONSTER) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只自己怪兽的等级上升或下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		-- 若该怪兽等级在2以上，则让玩家选择是上升1星还是下降1星；等级不足2时只能上升1星。
		if tc:IsLevelAbove(2) and Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==1 then  --"上升等级/下降等级"
			e1:SetValue(-1)
		else
			e1:SetValue(1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 发动条件判定：确认场地区域（双方任一侧）有卡存在。
function s.spcon(e)
	-- 检查以自己来看双方场地区域是否存在至少1张卡。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 发动时确认自己主要怪兽区有空位，并且这张卡可以从手卡特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己主要怪兽区可用的空格数大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将以这张卡为对象进行1次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与当前连锁关联，则把这张卡从手卡以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏对象的过滤函数：表侧表示的魔法·陷阱卡。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检索的过滤函数：攻击力0、机械族、风属性且可以加入手卡的怪兽。
function s.thfilter(c)
	return c:IsAttack(0) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- 目标阶段：候选对象判定为自己场上这张卡以外的表侧表示魔法·陷阱卡；发动时确认场上存在可作为对象的这类卡且卡组存在满足检索条件的怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动时检查自己场上存在这张卡以外、能成为对象的表侧表示魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 并检查自己卡组存在满足条件的攻击力0机械族·风属性怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送提示消息：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张表侧表示的魔法·陷阱卡并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置操作信息：本连锁将破坏作为对象的那1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本连锁将从卡组把1张卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取得对象卡，若其仍与连锁关联则将其效果破坏；破坏成功后让玩家从卡组选择1只满足条件的攻击力0机械族·风属性怪兽加入手卡，并让对方确认；随后注册一个本回合内限制自己从额外卡组特殊召唤非机械族怪兽的全场效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与连锁关联，则以效果将其破坏，并确认破坏成功后才继续处理。
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 向玩家发送提示消息：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己卡组选择1只攻击力0的机械族·风属性怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 以效果原因把选择的卡加入持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把该特殊召唤限制效果注册给自己玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件的过滤函数：从额外卡组特殊召唤的怪兽不是机械族时适用限制。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
