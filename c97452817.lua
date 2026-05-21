--アルカナフォースⅩⅧ－THE MOON
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：自己的准备阶段时可以在自己场上把1只「月衍生物」（天使族·光·1星·攻/守0）特殊召唤。
-- ●里：自己的结束阶段时只有1次，选择自己场上1只怪兽，那只怪兽的控制权转移给对方。
function c97452817.initial_effect(c)
	-- 注册召唤、反转召唤、特殊召唤成功时进行投掷硬币的效果
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：自己的准备阶段时可以在自己场上把1只「月衍生物」（天使族·光·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97452817,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c97452817.spcon)
	e1:SetTarget(c97452817.sptg)
	e1:SetOperation(c97452817.spop)
	c:RegisterEffect(e1)
	-- ●里：自己的结束阶段时只有1次，选择自己场上1只怪兽，那只怪兽的控制权转移给对方。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97452817,2))  --"控制权转移"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c97452817.ctcon)
	e2:SetTarget(c97452817.cttg)
	e2:SetOperation(c97452817.ctop)
	c:RegisterEffect(e2)
end
-- 判定当前是否为自己的准备阶段，且硬币投掷结果为表（正面）
function c97452817.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 特殊召唤「月衍生物」效果的发动条件与效果处理的准备判定
function c97452817.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的「月衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,97452818,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置当前连锁的操作信息为产生1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置当前连锁的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤「月衍生物」的效果处理
function c97452817.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若不能特殊召唤指定的「月衍生物」则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,97452818,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	-- 创建「月衍生物」的卡片数据
	local token=Duel.CreateToken(tp,97452818)
	-- 将创建的「月衍生物」以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 判定当前是否为自己的结束阶段，且硬币投掷结果为里（反面）
function c97452817.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 转移控制权效果的发动条件与对象选择判定
function c97452817.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return true end
	-- 提示玩家选择要转移控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只可以转移控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为转移所选怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 转移控制权的效果处理
function c97452817.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 将目标怪兽的控制权转移给对方
		Duel.GetControl(tc,1-tp)
	end
end
