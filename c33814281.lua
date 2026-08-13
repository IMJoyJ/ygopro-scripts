--特許権の契約書類
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：和自己场上的「DDD」怪兽相同种类（融合·同调·超量·连接）的怪兽由对方特殊召唤的场合才能发动。给与对方1000伤害。这个回合，这张卡在场上存在期间，对方不能把和那些特殊召唤的怪兽相同种类的怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只「DD」怪兽加入手卡。
function c33814281.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：和自己场上的「DDD」怪兽相同种类（融合·同调·超量·连接）的怪兽由对方特殊召唤的场合才能发动。给与对方1000伤害。这个回合，这张卡在场上存在期间，对方不能把和那些特殊召唤的怪兽相同种类的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c33814281.spcon)
	e2:SetTarget(c33814281.sptg)
	e2:SetOperation(c33814281.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的场合才能发动。从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只「DD」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,33814281)
	e3:SetTarget(c33814281.thtg)
	e3:SetOperation(c33814281.thop)
	c:RegisterEffect(e3)
end
-- 判断刚刚特殊召唤成功的怪兽是否为对方玩家特殊召唤，并取出其种类（融合/同调/超量/连接）rtype；再检查己方场上是否存在表侧表示且含有「DDD」字段、种类包含rtype的怪兽。
function c33814281.limfilter(c,tp)
	local rtype=c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	return c:GetSummonPlayer()==1-tp and rtype>0
		-- 检查己方场上是否存在1只表侧表示的「DDD」怪兽，且其种类包含rtype（即与对方特殊召唤的怪兽相同种类）。
		and Duel.IsExistingMatchingCard(c33814281.cfilter,tp,LOCATION_MZONE,0,1,nil,rtype)
end
-- 判断怪兽是否满足：表侧表示、卡名含有「DDD」字段，且其种类包含指定的rtype（融合/同调/超量/连接之一）。
function c33814281.cfilter(c,rtype)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:GetType()&rtype>0
end
-- 触发条件：对方特殊召唤的怪兽中存在满足limfilter条件（与己方场上「DDD」怪兽同一种类）的怪兽。
function c33814281.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33814281.limfilter,1,nil,tp)
end
-- 发动时的目标处理：效果可以发动；将伤害对象设为对方，伤害值为1000，并登记伤害效果的操作信息。
function c33814281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前效果的对象玩家设置为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前效果的对象参数设置为1000，表示后续造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记本连锁的伤害操作信息：给对方玩家造成1000点伤害（不取对象，目标卡不确定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：给对方造成1000伤害；筛选出触发条件的对方特殊召唤怪兽，针对其中涉及的种类，给这张卡注册永续效果，使这个回合对方不能特殊召唤相同种类的怪兽，并为每个种类添加客户端提示标记。
function c33814281.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家造成1000点伤害，伤害原因为效果（REASON_EFFECT）。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
	local c=e:GetHandler()
	local g=eg:Filter(c33814281.limfilter,nil,tp)
	local tc=g:GetFirst()
	while tc do
		local rtype=tc:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		-- 这个回合，这张卡在场上存在期间，对方不能把和那些特殊召唤的怪兽相同种类的怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_FZONE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(reset)
		e1:SetTargetRange(0,1)
		e1:SetLabel(rtype)
		e1:SetTarget(c33814281.sumlimit)
		c:RegisterEffect(e1)
		if (rtype&TYPE_FUSION)>0 and c:GetFlagEffect(33814281)==0 then
			c:RegisterFlagEffect(33814281,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(33814281,0))  --"不能再特殊召唤融合怪兽"
		end
		if (rtype&TYPE_SYNCHRO)>0 and c:GetFlagEffect(33814282)==0 then
			c:RegisterFlagEffect(33814282,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(33814281,1))  --"不能再特殊召唤同调怪兽"
		end
		if (rtype&TYPE_XYZ)>0 and c:GetFlagEffect(33814283)==0 then
			c:RegisterFlagEffect(33814283,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(33814281,2))  --"不能再特殊召唤超量怪兽"
		end
		if (rtype&TYPE_LINK)>0 and c:GetFlagEffect(33814284)==0 then
			c:RegisterFlagEffect(33814284,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(33814281,3))  --"不能再特殊召唤连接怪兽"
		end
		tc=g:GetNext()
	end
end
-- 限制效果的判定：若将要特殊召唤的怪兽c的种类包含此效果记录的rtype（e:GetLabel()），则禁止其特殊召唤。
function c33814281.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(e:GetLabel())
end
-- 检索条件：从自己墓地的怪兽以及自己额外卡组表侧表示的灵摆怪兽中，选择1只「DD」字段的怪兽，且该怪兽能够加入手卡。
function c33814281.thfilter(c)
	return (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsLocation(LOCATION_GRAVE))
		and c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件：自己墓地或额外卡组存在满足thfilter的「DD」怪兽；并设置将1张卡加入手卡的操作信息。
function c33814281.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认是否存在至少1张符合条件的「DD」怪兽（来自墓地或额外卡组的表侧灵摆怪兽）。
	if chk==0 then return Duel.IsExistingMatchingCard(c33814281.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 登记效果处理时要将1张卡加入手卡，检索位置为墓地+额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果处理：提示玩家选择1张符合条件的「DD」怪兽，将其加入手卡，并向对方展示。
function c33814281.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地和额外卡组的表侧灵摆怪兽中选择1张满足thfilter且不受「王家长眠之谷」影响的「DD」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33814281.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认操作。
		Duel.ConfirmCards(1-tp,g)
	end
end
