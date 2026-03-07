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
	-- ②：这张卡被送去墓地的场合才能发动。从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只「DD」怪兽加入手卡。
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
-- 过滤函数，用于判断对方特殊召唤的怪兽是否为「DDD」怪兽种类（融合·同调·超量·连接）且自己场上有对应种类的「DDD」怪兽。
function c33814281.limfilter(c,tp)
	local rtype=c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	return c:GetSummonPlayer()==1-tp and rtype>0
		-- 检查自己场上是否存在与对方特殊召唤的怪兽种类相同的「DDD」怪兽。
		and Duel.IsExistingMatchingCard(c33814281.cfilter,tp,LOCATION_MZONE,0,1,nil,rtype)
end
-- 过滤函数，用于判断自己场上的「DDD」怪兽是否与对方特殊召唤的怪兽种类相同。
function c33814281.cfilter(c,rtype)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:GetType()&rtype>0
end
-- 判断是否有对方特殊召唤的怪兽满足条件。
function c33814281.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33814281.limfilter,1,nil,tp)
end
-- 设置效果目标为对方玩家，设定伤害值为1000，准备发动伤害效果。
function c33814281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为1000。
	Duel.SetTargetParam(1000)
	-- 设置连锁效果的操作信息为对对方造成1000伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 发动效果，对对方造成1000伤害，并为对方场上的特殊召唤怪兽种类设置不能特殊召唤的限制。
function c33814281.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方玩家造成1000伤害。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
	local c=e:GetHandler()
	local g=eg:Filter(c33814281.limfilter,nil,tp)
	local tc=g:GetFirst()
	while tc do
		local rtype=tc:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		-- 创建一个场地区域的永续效果，禁止对方特殊召唤与该怪兽种类相同的怪兽。
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
-- 判断目标怪兽是否为指定种类的怪兽。
function c33814281.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(e:GetLabel())
end
-- 过滤函数，用于筛选自己墓地或额外卡组中符合条件的「DD」怪兽。
function c33814281.thfilter(c)
	return (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsLocation(LOCATION_GRAVE))
		and c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标为从自己墓地或额外卡组中选择一只「DD」怪兽加入手牌。
function c33814281.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或额外卡组中是否存在符合条件的「DD」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33814281.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁效果的操作信息为将一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 发动效果，从自己墓地或额外卡组中选择一只「DD」怪兽加入手牌。
function c33814281.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地或额外卡组中选择一张符合条件的「DD」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33814281.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
