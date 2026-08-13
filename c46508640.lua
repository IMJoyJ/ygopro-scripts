--龍脈に棲む者
-- 效果：
-- ①：这张卡的攻击力上升自己的魔法与陷阱区域的永续魔法卡数量×300。
function c46508640.initial_effect(c)
	-- ①：这张卡的攻击力上升自己的魔法与陷阱区域的永续魔法卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c46508640.atkval)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定一张卡是否为表侧表示且类型为永续魔法卡，并排除场地魔法区域（序号5），用于后续筛选自己魔法与陷阱区域中符合条件的永续魔法卡。
function c46508640.cfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:GetSequence()~=5
end
-- 攻击力变化值的计算函数：根据此卡控制者场上满足过滤条件的永续魔法卡数量，每张提升300攻击力，作为EFFECT_UPDATE_ATTACK的Value值。
function c46508640.atkval(e,c)
	-- 统计此卡控制者自己的魔法与陷阱区域中满足cfilter条件的卡的数量，并乘以300，得到攻击力上升的具体数值。
	return Duel.GetMatchingGroupCount(c46508640.cfilter,c:GetControler(),LOCATION_SZONE,0,nil)*300
end
