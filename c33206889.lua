--Emトラピーズ・フォース・ウィッチ
-- 效果：
-- 「娱乐法师」怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己场上的「娱乐法师」怪兽不会被自己的卡的效果破坏，对方不能把那些作为效果的对象。
-- ②：只要自己场上有「娱乐法师 秋千魄力魔女」以外的「娱乐法师」怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
-- ③：自己的「娱乐法师」怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力下降600。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤条件、苏生限制和四个效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用2个融合集为娱乐法师的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc6),2,true)
	c:EnableReviveLimit()
	-- 效果1：自己场上的娱乐法师怪兽不会被自己的卡的效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果1的目标为场上的娱乐法师怪兽（正面表示）
	e1:SetTarget(aux.TargetBoolFunction(aux.AND(Card.IsSetCard,Card.IsFaceup),0xc6))
	-- 设置效果1的值为取反的indoval函数，即不会被自己卡的效果破坏
	e1:SetValue(aux.NOT(aux.indoval))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果2的值为tgoval函数，即对方不能把那些作为效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 效果3：对方怪兽不能选择这张卡作为攻击对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetCondition(s.atkcon)
	-- 设置效果3的值为imval1函数，即不会成为攻击对象
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- 效果4：自己的娱乐法师怪兽和对方怪兽进行战斗的攻击宣言时才能发动，使对方怪兽攻击力下降600
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"降低攻击力"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon2)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上有除自身外的娱乐法师怪兽
function s.cfilter(c)
	return not c:IsCode(id) and c:IsFaceup() and c:IsSetCard(0xc6)
end
-- 条件函数，判断是否满足效果3的发动条件
function s.atkcon(e)
	-- 检查场上是否存在满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 条件函数，判断是否满足效果4的发动条件，设置攻击对象
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not d or a:GetControler()==d:GetControler() or d:IsFacedown() or a:IsFacedown() then return end
	if a:IsControler(tp) and a:IsSetCard(0xc6) then e:SetLabelObject(d)
	elseif d:IsControler(tp) and d:IsSetCard(0xc6) then e:SetLabelObject(a)
	else return false end
	return true
end
-- 效果目标函数，设置攻击目标怪兽为效果4的目标
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:IsOnField() end
	-- 设置当前连锁处理的对象为tc
	Duel.SetTargetCard(tc)
end
-- 效果处理函数，使对方怪兽攻击力下降600
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
		-- 创建攻击力变更效果，使目标怪兽攻击力下降600
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
