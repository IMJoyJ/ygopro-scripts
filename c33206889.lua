--Emトラピーズ・フォース・ウィッチ
-- 效果：
-- 「娱乐法师」怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己场上的「娱乐法师」怪兽不会被自己的卡的效果破坏，对方不能把那些作为效果的对象。
-- ②：只要自己场上有「娱乐法师 秋千魄力魔女」以外的「娱乐法师」怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
-- ③：自己的「娱乐法师」怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力下降600。
local s,id,o=GetID()
-- 初始化函数：为该卡注册融合召唤手续（2只「娱乐法师」怪兽作为融合素材）、苏生限制及①②③效果；其中e1/e2实现①的己方效果破坏免疫和对方效果对象免疫，e3实现②的攻击对象限制，e4实现③的攻击宣言降低对方怪兽攻击力。
function s.initial_effect(c)
	-- 添加融合召唤手续：以2只满足字段「娱乐法师」（0xc6）的怪兽作为融合素材，允许通过融合召唤召唤此卡。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc6),2,true)
	c:EnableReviveLimit()
	-- 对应①前半句：只要这张卡在怪兽区域存在，自己场上的「娱乐法师」怪兽不会被自己的卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设定该保护效果的对象范围：自己场上表侧表示的「娱乐法师」怪兽（与SetTargetRange组合实现只保护自己场上符合条件的怪兽）。
	e1:SetTarget(aux.TargetBoolFunction(aux.AND(Card.IsSetCard,Card.IsFaceup),0xc6))
	-- 设定免疫判定值：取反aux.indoval后，使效果来自己方时返回真，从而实现“不会被自己的卡的效果破坏”。
	e1:SetValue(aux.NOT(aux.indoval))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设定“不能成为效果对象”的判定值：使对方的效果不能选择这些「娱乐法师」怪兽作为对象（对应①后半句）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 对应②：只要自己场上有「娱乐法师 秋千魄力魔女」以外的「娱乐法师」怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetCondition(s.atkcon)
	-- 设定不能成为攻击对象的判定值：对方怪兽不能选择此卡作为攻击对象。
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- 对应③：自己的「娱乐法师」怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力下降600。
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
-- 过滤器：选出不是这张卡、表侧表示且属于「娱乐法师」字段的怪兽，用于②的适用条件检测。
function s.cfilter(c)
	return not c:IsCode(id) and c:IsFaceup() and c:IsSetCard(0xc6)
end
-- ②的适用条件：检查自己场上是否存在这张卡以外的表侧表示「娱乐法师」怪兽，存在则对方怪兽不能攻击这张卡。
function s.atkcon(e)
	-- 检查自己怪兽区域是否存在至少1张满足s.cfilter条件的卡（非本卡、表侧表示的「娱乐法师」怪兽）。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 攻击宣言时的条件判定：确认战斗双方是己方「娱乐法师」怪兽与对方怪兽，并将对方那只怪兽记录到效果e的标签中，供发动时使用。
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	if not d or a:GetControler()==d:GetControler() or d:IsFacedown() or a:IsFacedown() then return end
	if a:IsControler(tp) and a:IsSetCard(0xc6) then e:SetLabelObject(d)
	elseif d:IsControler(tp) and d:IsSetCard(0xc6) then e:SetLabelObject(a)
	else return false end
	return true
end
-- 发动时的取对象处理：读取记录的对方怪兽，确认其仍在场上并设置为效果对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:IsOnField() end
	-- 将tc正式设置为当前连锁的对象，后续通过Duel.GetFirstTarget()取得。
	Duel.SetTargetCard(tc)
end
-- 效果处理：对作为对象的对方怪兽赋予攻击力下降600的持续效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中由SetTargetCard设置的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
		-- 对应③处理部分：那只对方怪兽的攻击力下降600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
