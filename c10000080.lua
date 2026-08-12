--ラーの翼神竜－球体形
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤或者把对方场上3只怪兽解放在对方场上召唤，召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
-- ①：这张卡不能攻击，不会成为对方的攻击·效果的对象。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
function c10000080.initial_effect(c)
	-- 声明该卡的代码列表中包含太阳神之翼神龙
	aux.AddCodeList(c,10000010)
	-- 开启控制权转移（洗脑）状态检查的全局标记，以便跟踪卡片原本持有者
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- 这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000080,0))  --"在自己场上召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000080.ttcon1)
	e1:SetOperation(c10000080.ttop1)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 或者把对方场上3只怪兽解放在对方场上召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10000080,1))  --"在对方场上召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e2:SetTargetRange(POS_FACEUP_ATTACK,1)
	e2:SetCondition(c10000080.ttcon2)
	e2:SetOperation(c10000080.ttop2)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤或者把对方场上3只怪兽解放在对方场上召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LIMIT_SET_PROC)
	e3:SetCondition(c10000080.setcon)
	c:RegisterEffect(e3)
	-- 这张卡不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e4)
	-- 召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetOperation(c10000080.retreg)
	c:RegisterEffect(e5)
	-- ①：这张卡不能攻击
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e6)
	-- 不会成为对方的攻击·效果的对象。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetRange(LOCATION_MZONE)
	-- 用于判定该卡不会被对方选择为攻击对象
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 用于判定该卡不会被对方选择为效果对象
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(10000080,2))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCost(c10000080.spcost)
	e9:SetTarget(c10000080.sptg)
	e9:SetOperation(c10000080.spop)
	c:RegisterEffect(e9)
end
-- 自己场上上级召唤条件检查：检查解放怪兽数量是否为3，且自己场上存在3只可解放的怪兽
function c10000080.ttcon1(e,c,minc)
	if c==nil then return true end
	-- 检查用于解放 of 怪兽数量是否满足3只
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 自己场上上级召唤操作函数：选择自己场上3只怪兽解放，并将其设为召唤素材
function c10000080.ttop1(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择自己场上3只怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 释放选中的怪兽作为召唤的祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 对方场上上级召唤条件检查：检查解放怪兽数量是否为3，且对方场上存在3只可解放的怪兽
function c10000080.ttcon2(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上的所有怪兽
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 检查对方场上是否存在3只可解放的怪兽
	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp)
end
-- 对方场上上级召唤操作函数：选择对方场上3只怪兽解放，并将它们作为召唤素材
function c10000080.ttop2(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方场上的所有怪兽
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 让玩家选择对方场上的3只怪兽
	local g=Duel.SelectTribute(tp,c,3,3,mg,1-tp)
	c:SetMaterial(g)
	-- 解放对方场上选中的3只怪兽以在对方场上召唤此卡
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 里侧盖放限制：阻止玩家将这张卡直接里侧盖放（Set）召唤
function c10000080.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 控制权回归注册：在召唤成功时注册时点，并在下个回合结束阶段时触发回归控制权的处理
function c10000080.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(10000080,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)
	-- 召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 将效果的触发回合标记为下个回合
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetCountLimit(1)
	e1:SetCondition(c10000080.retcon)
	e1:SetOperation(c10000080.retop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将注册好的回归事件效果应用到决斗中
	Duel.RegisterEffect(e1,tp)
end
-- 控制权回归条件检查：检查当前回合数是否是召唤的下个回合，且该卡确实带有回归标记
function c10000080.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合数是否是原先记录的目标回合，并确认球体形怪兽卡依旧具有注册标记
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(10000080)~=0
end
-- 控制权回归操作函数：注册移除洗脑（控制权转移）效果以恢复此卡的原本控制权，并在操作完毕后重置此效果
function c10000080.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	-- 召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(c)
	e1:SetTarget(c10000080.rettg)
	-- 向决斗中注册用于恢复怪兽原本控制权的效果
	Duel.RegisterEffect(e1,tp)
	-- 召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(c10000080.reset)
	-- 注册一个在游戏状态调整时触发的效果，用于重置回归控制权效果
	Duel.RegisterEffect(e2,tp)
end
-- 控制权回归目标判定：用于检查目标怪兽是否是当前的球体形怪兽本身
function c10000080.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(10000080)~=0
end
-- 重置函数：将控制权回归效果以及其调整重置效果彻底重置并清理
function c10000080.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
-- 特殊召唤效果代价函数：检查此卡是否可以被解放，如果是则解放此卡
function c10000080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身作为效果的发动代价进行解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选出可被特殊召唤的太阳神之翼神龙
function c10000080.filter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果目标函数：检查自己怪兽区域是否有位置，以及手牌·卡组中是否存在可以特殊召唤的太阳神之翼神龙
function c10000080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区域是否能容纳新的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查玩家手牌或卡组中是否存在符合特殊召唤条件的太阳神之翼神龙
		and Duel.IsExistingMatchingCard(c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定效果处理的预估信息：从手牌或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果操作函数：从手牌·卡组中特殊召唤1只太阳神之翼神龙，无视其召唤条件，并将其攻击力和守备力数值设定为4000
function c10000080.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果控制者场上没有空余怪兽区域，则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择1只符合条件的太阳神之翼神龙
	local g=Duel.SelectMatchingCard(tp,c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择，则在无视召唤条件的情况下执行特殊召唤的步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 并攻击力·守备力变成4000特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(4000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
